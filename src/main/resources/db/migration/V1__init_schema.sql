-- ==========================================================================================
-- 항공기 도메인 스키마
-- Temporal 설계 적용 범위:
--   - TBL_ACFT_MDL / TBL_ACFT : DEL_YN 논리삭제만 허용
--   - TBL_FLT_SCHDL            : UPDATE 허용 — 지연·취소 변경이력은 TBL_FLT_SCHDL_HSTRY 에 기록
--   - TBL_FLT_SCHDL_HSTRY      : Append-only (물리·논리 삭제 모두 금지)
-- ==========================================================================================


-- ==========================================================================================
-- 기종 마스터 테이블 (TBL_ACFT_MDL)
-- 항공사가 보유·운용하는 항공기 기종 마스터. 기종 단종 시 DEL_YN='Y' 처리
-- ==========================================================================================

CREATE TABLE TBL_ACFT_MDL
(
    ACFT_MDL_ID       VARCHAR(30)   NOT NULL COMMENT '기종_식별자'                                                                                      PRIMARY KEY,
    ACFT_MDL_CD       VARCHAR(10)   NOT NULL COMMENT '기종_코드 — ICAO 항공기 유형 지정자(예:B738=보잉737-800, B77W=보잉777-300ER, A388=에어버스A380-800)',
    ACFT_MDL_NM       VARCHAR(100)  NOT NULL COMMENT '기종_명 — 상품 표시용 정식 명칭(예:Boeing 737-800)',
    MKR_NM            VARCHAR(100)  NOT NULL COMMENT '제조사_명 — 항공기 제조사(예:Boeing, Airbus)',
    ECO_TOT_SEAT_CNT  SMALLINT      NOT NULL COMMENT '이코노미_총_좌석_수 — 기종 기본 사양 기준 이코노미 좌석 수',
    BIZ_TOT_SEAT_CNT  SMALLINT      NOT NULL COMMENT '비즈니스_총_좌석_수',
    FRST_TOT_SEAT_CNT SMALLINT      NOT NULL COMMENT '일등석_총_좌석_수 — 일등석 없는 기종은 0',
    MAX_RNG_KM        INT           NOT NULL COMMENT '최대_항속거리_KM — 최대 비행 가능 거리(km). A380=15,200km로 INT 사용',
    CRS_SPD_KMH       SMALLINT      NOT NULL COMMENT '순항_속도_KMH — 순항 속도(km/h)',
    MDL_YR            SMALLINT      NOT NULL COMMENT '모델_연도 — 기종 최초 출시 연도(4자리)',
    DEL_YN            VARCHAR(1)    DEFAULT 'N' NOT NULL COMMENT '삭제_여부 — N:정상, Y:삭제(논리 삭제만 허용)',
    REG_DT            DATETIME      DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT '등록_일시',
    RGTR_ID           VARCHAR(30)   NOT NULL COMMENT '등록자_아이디',
    MDFCN_DT          DATETIME      DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT '수정_일시',
    MDFR_ID           VARCHAR(30)   NOT NULL COMMENT '수정자_아이디'
) COMMENT '기종 — 항공기 기종 마스터' COLLATE = UTF8MB4_UNICODE_CI;

-- 기종 코드 유일성 보장
CREATE UNIQUE INDEX UK_ACFT_MDL_CD ON TBL_ACFT_MDL (ACFT_MDL_CD);


-- ==========================================================================================
-- 항공기 테이블 (TBL_ACFT)
-- 항공사가 보유한 개별 항공기 인스턴스. 정비 시 ACFT_STTS_CD='MNTC', 퇴역 시 'RETD'
-- ==========================================================================================

CREATE TABLE TBL_ACFT
(
    ACFT_ID      VARCHAR(30)   NOT NULL COMMENT '항공기_식별자'                                                                                         PRIMARY KEY,
    ACFT_MDL_ID  VARCHAR(30)   NOT NULL COMMENT '기종_식별자 — TBL_ACFT_MDL.ACFT_MDL_ID 참조',
    ARLN_CD      VARCHAR(3)    NOT NULL COMMENT '항공사_코드 — IATA 2자리 항공사 코드(예:KE=대한항공, OZ=아시아나)',
    RGST_NO      VARCHAR(10)   NOT NULL COMMENT '등록_번호 — 항공기 국적 등록 기호(예:HL7612). 한국 항공기는 HL 접두사. _NO suffix: 식별자가 아닌 번호',
    ACFT_STTS_CD VARCHAR(10)   NOT NULL COMMENT '항공기_상태_코드 — ACTV(운항중)/MNTC(정비중)/RETD(퇴역)',
    DEL_YN       VARCHAR(1)    DEFAULT 'N' NOT NULL COMMENT '삭제_여부 — N:정상, Y:삭제(논리 삭제만 허용)',
    REG_DT       DATETIME      DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT '등록_일시',
    RGTR_ID      VARCHAR(30)   NOT NULL COMMENT '등록자_아이디',
    MDFCN_DT     DATETIME      DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT '수정_일시',
    MDFR_ID      VARCHAR(30)   NOT NULL COMMENT '수정자_아이디'
) COMMENT '항공기 — 항공사 보유 항공기 인스턴스' COLLATE = UTF8MB4_UNICODE_CI;

-- 등록번호 유일성 보장 (ICAO 규정: 항공기 등록번호는 전 세계 고유)
CREATE UNIQUE INDEX UK_ACFT_RGST_NO ON TBL_ACFT (RGST_NO);
-- 항공사별 운항 가능 항공기 조회
CREATE INDEX IDX_ACFT_ARLN ON TBL_ACFT (ARLN_CD, ACFT_STTS_CD);


-- ==========================================================================================
-- 항공스케줄 테이블 (TBL_FLT_SCHDL)
-- 편당 출발 스케줄. 지연·취소 발생 시 UPDATE 허용 — 변경 전후 상태는 TBL_FLT_SCHDL_HSTRY 에 기록
-- 좌석 수는 기종 교체 대비 스케줄 생성 시점에 비정규화하여 저장
-- ==========================================================================================

CREATE TABLE TBL_FLT_SCHDL
(
    FLT_SCHDL_ID       VARCHAR(30)   NOT NULL COMMENT '항공스케줄_식별자'                                                                               PRIMARY KEY,
    ACFT_ID            VARCHAR(30)   NOT NULL COMMENT '항공기_식별자 — TBL_ACFT.ACFT_ID 참조',
    ARLN_CD            VARCHAR(3)    NOT NULL COMMENT '항공사_코드 — IATA 2자리 항공사 코드(예:KE=대한항공)',
    FLT_NO             VARCHAR(10)   NOT NULL COMMENT '항공편_번호 — IATA 항공편 번호(예:KE721). 항공사 코드 포함한 전체 편명. _NO suffix: 식별자가 아닌 번호',
    DPTRE_ARPT_CD      VARCHAR(3)    NOT NULL COMMENT '출발_공항_코드 — IATA 3자리 공항 코드(예:ICN=인천)',
    ARVL_ARPT_CD       VARCHAR(3)    NOT NULL COMMENT '도착_공항_코드 — IATA 3자리 공항 코드(예:NRT=나리타)',
    EST_DPTRE_DT       DATETIME      NOT NULL COMMENT '예상_출발_일시 — 예정 출발 일시. 지연 발생 시 이 값이 변경됨',
    EST_ARVL_DT        DATETIME      NOT NULL COMMENT '예상_도착_일시 — 예정 도착 일시. 지연 발생 시 이 값이 변경됨',
    ACTL_DPTRE_DT      DATETIME      NULL     COMMENT '실제_출발_일시 — 실제 출발 후 기록. 미출발 시 NULL',
    ACTL_ARVL_DT       DATETIME      NULL     COMMENT '실제_도착_일시 — 실제 도착 후 기록. 미도착 시 NULL',
    FLT_STTS_CD        VARCHAR(10)   NOT NULL COMMENT '항공편_상태_코드 — SCHD(예정)/BRDG(탑승중)/DPRD(출발)/DLYD(지연)/CNCL(취소)/ARVD(도착완료)',
    DLY_RSN_CD         VARCHAR(20)   NULL     COMMENT '지연_사유_코드 — 지연 발생 시만 값 존재(예:WTHR=기상, MCHL=기계결함, TRFC=관제)',
    DLY_RMRK           VARCHAR(200)  NULL     COMMENT '지연_비고 — 지연 사유 상세 설명. 지연 없으면 NULL',
    ECO_TOT_SEAT_CNT   SMALLINT      NOT NULL COMMENT '이코노미_총_좌석_수 — 스케줄 생성 시 기종 정보에서 복사(기종 교체 대비 비정규화)',
    BIZ_TOT_SEAT_CNT   SMALLINT      NOT NULL COMMENT '비즈니스_총_좌석_수',
    FRST_TOT_SEAT_CNT  SMALLINT      NOT NULL COMMENT '일등석_총_좌석_수',
    ECO_AVBL_SEAT_CNT  SMALLINT      NOT NULL COMMENT '이코노미_잔여_좌석_수 — 예약 시 감소. 초기값 = ECO_TOT_SEAT_CNT',
    BIZ_AVBL_SEAT_CNT  SMALLINT      NOT NULL COMMENT '비즈니스_잔여_좌석_수',
    FRST_AVBL_SEAT_CNT SMALLINT      NOT NULL COMMENT '일등석_잔여_좌석_수',
    DEL_YN             VARCHAR(1)    DEFAULT 'N' NOT NULL COMMENT '삭제_여부 — N:정상, Y:삭제(논리 삭제만 허용)',
    REG_DT             DATETIME      DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT '등록_일시',
    RGTR_ID            VARCHAR(30)   NOT NULL COMMENT '등록자_아이디',
    MDFCN_DT           DATETIME      DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT '수정_일시 — 지연·취소 등 상태 변경 시 갱신',
    MDFR_ID            VARCHAR(30)   NOT NULL COMMENT '수정자_아이디'
) COMMENT '항공스케줄 — 편당 출발 스케줄, 상태·지연 관리' COLLATE = UTF8MB4_UNICODE_CI;

-- 노선·날짜 기준 스케줄 조회 핵심 인덱스
CREATE INDEX IDX_FLT_SCHDL_LOOKUP ON TBL_FLT_SCHDL (ARLN_CD, DPTRE_ARPT_CD, ARVL_ARPT_CD, EST_DPTRE_DT);
-- 특정 항공기의 스케줄 조회 (정비 일정 충돌 확인)
CREATE INDEX IDX_FLT_SCHDL_ACFT ON TBL_FLT_SCHDL (ACFT_ID, EST_DPTRE_DT);
-- 운영 대시보드: 지연·취소 편 실시간 조회
CREATE INDEX IDX_FLT_SCHDL_STTS ON TBL_FLT_SCHDL (FLT_STTS_CD, EST_DPTRE_DT);


-- ==========================================================================================
-- 항공스케줄 변경이력 테이블 (TBL_FLT_SCHDL_HSTRY)
-- Append-only: 물리·논리 삭제 및 UPDATE 금지. DEL_YN·MDFCN_DT·MDFR_ID 없음
-- 스케줄 변경(지연·취소·일정변경) 발생 시 변경 전후 상태를 이 테이블에 INSERT
-- ==========================================================================================

CREATE TABLE TBL_FLT_SCHDL_HSTRY
(
    FLT_SCHDL_HSTRY_ID VARCHAR(30)   NOT NULL COMMENT '항공스케줄_이력_식별자'                                                                          PRIMARY KEY,
    FLT_SCHDL_ID       VARCHAR(30)   NOT NULL COMMENT '항공스케줄_식별자 — TBL_FLT_SCHDL.FLT_SCHDL_ID 참조',
    CHG_TP_CD          VARCHAR(20)   NOT NULL COMMENT '변경_유형_코드 — SCHDL_CHG(일정변경)/STTS_CHG(상태변경)/DLY_REG(지연등록)/CNCL(취소)',
    BFR_FLT_STTS_CD    VARCHAR(10)   NULL     COMMENT '변경전_항공편_상태_코드 — 변경 이전 상태값. 최초 등록 시 NULL',
    AFT_FLT_STTS_CD    VARCHAR(10)   NOT NULL COMMENT '변경후_항공편_상태_코드 — 변경 이후 상태값',
    BFR_EST_DPTRE_DT   DATETIME      NULL     COMMENT '변경전_예상_출발_일시 — 일정 변경이 없으면 NULL',
    AFT_EST_DPTRE_DT   DATETIME      NULL     COMMENT '변경후_예상_출발_일시 — 일정 변경이 없으면 NULL',
    BFR_EST_ARVL_DT    DATETIME      NULL     COMMENT '변경전_예상_도착_일시',
    AFT_EST_ARVL_DT    DATETIME      NULL     COMMENT '변경후_예상_도착_일시',
    DLY_RSN_CD         VARCHAR(20)   NULL     COMMENT '지연_사유_코드 — 지연 등록 시만 값 존재',
    RMRK               VARCHAR(200)  NULL     COMMENT '비고 — 변경 사유 상세 설명',
    REG_DT             DATETIME      DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT '등록일시 — 이력 발생 일시',
    RGTR_ID           VARCHAR(30)   NOT NULL COMMENT '등록자_아이디 — 스케줄 변경을 처리한 담당자 ID'
) COMMENT '항공스케줄_이력 — Append-only 변경이력, 수정·삭제 금지' COLLATE = UTF8MB4_UNICODE_CI;

-- 스케줄별 변경이력 시계열 조회
CREATE INDEX IDX_FLT_SCHDL_HSTRY_SCHDL ON TBL_FLT_SCHDL_HSTRY (FLT_SCHDL_ID, REG_DT);


-- ==========================================================================================
-- FK 제약 (모든 테이블 생성 후 일괄 추가)
-- ==========================================================================================

ALTER TABLE TBL_ACFT
    ADD CONSTRAINT FK_ACFT_MDL
        FOREIGN KEY (ACFT_MDL_ID) REFERENCES TBL_ACFT_MDL (ACFT_MDL_ID);

ALTER TABLE TBL_FLT_SCHDL
    ADD CONSTRAINT FK_FLT_SCHDL_ACFT
        FOREIGN KEY (ACFT_ID) REFERENCES TBL_ACFT (ACFT_ID);

ALTER TABLE TBL_FLT_SCHDL_HSTRY
    ADD CONSTRAINT FK_FLT_SCHDL_HSTRY_SCHDL
        FOREIGN KEY (FLT_SCHDL_ID) REFERENCES TBL_FLT_SCHDL (FLT_SCHDL_ID);
