-- ==========================================================================================
-- 항공기 도메인 시드 데이터
-- 기종(3건) → 항공기(3건) → 스케줄(4건) → 스케줄이력(2건) 순으로 INSERT
-- KE721 ICN→NRT 편: 지연 시나리오 검증용 (DLYD + HSTRY 2건)
-- ==========================================================================================


-- ==========================================================================================
-- TBL_ACFT_MDL — 기종 마스터 (3종)
-- ==========================================================================================

-- ① Boeing 737-800 (단거리 기종, 일등석 없음 — FRST_TOT_SEAT_CNT=0)
INSERT INTO TBL_ACFT_MDL
    (ACFT_MDL_ID, ACFT_MDL_CD, ACFT_MDL_NM, MKR_NM,
     ECO_TOT_SEAT_CNT, BIZ_TOT_SEAT_CNT, FRST_TOT_SEAT_CNT,
     MAX_RNG_KM, CRS_SPD_KMH, MDL_YR,
     DEL_YN, REG_DT, RGTR_ID, MDFCN_DT, MDFR_ID)
VALUES
    ('ACFT_MDL001', 'B738', 'Boeing 737-800', 'Boeing',
     162, 12, 0,
     5765, 842, 1998,
     'N', NOW(), 'sysadmin', NOW(), 'sysadmin');

-- ② Boeing 777-300ER (장거리 와이드바디)
INSERT INTO TBL_ACFT_MDL
    (ACFT_MDL_ID, ACFT_MDL_CD, ACFT_MDL_NM, MKR_NM,
     ECO_TOT_SEAT_CNT, BIZ_TOT_SEAT_CNT, FRST_TOT_SEAT_CNT,
     MAX_RNG_KM, CRS_SPD_KMH, MDL_YR,
     DEL_YN, REG_DT, RGTR_ID, MDFCN_DT, MDFR_ID)
VALUES
    ('ACFT_MDL002', 'B77W', 'Boeing 777-300ER', 'Boeing',
     262, 52, 8,
     13650, 905, 2003,
     'N', NOW(), 'sysadmin', NOW(), 'sysadmin');

-- ③ Airbus A380-800 (초대형 더블데크)
INSERT INTO TBL_ACFT_MDL
    (ACFT_MDL_ID, ACFT_MDL_CD, ACFT_MDL_NM, MKR_NM,
     ECO_TOT_SEAT_CNT, BIZ_TOT_SEAT_CNT, FRST_TOT_SEAT_CNT,
     MAX_RNG_KM, CRS_SPD_KMH, MDL_YR,
     DEL_YN, REG_DT, RGTR_ID, MDFCN_DT, MDFR_ID)
VALUES
    ('ACFT_MDL003', 'A388', 'Airbus A380-800', 'Airbus',
     407, 94, 12,
     15200, 903, 2007,
     'N', NOW(), 'sysadmin', NOW(), 'sysadmin');


-- ==========================================================================================
-- TBL_ACFT — 항공기 인스턴스 (3대, 모두 대한항공 KE)
-- ==========================================================================================

INSERT INTO TBL_ACFT
    (ACFT_ID, ACFT_MDL_ID, ARLN_CD, RGST_NO, ACFT_STTS_CD,
     DEL_YN, REG_DT, RGTR_ID, MDFCN_DT, MDFR_ID)
VALUES
    ('ACFT001', 'ACFT_MDL001', 'KE', 'HL7612', 'ACTV', 'N', NOW(), 'sysadmin', NOW(), 'sysadmin'),  -- B738
    ('ACFT002', 'ACFT_MDL002', 'KE', 'HL7721', 'ACTV', 'N', NOW(), 'sysadmin', NOW(), 'sysadmin'),  -- B77W
    ('ACFT003', 'ACFT_MDL003', 'KE', 'HL7634', 'ACTV', 'N', NOW(), 'sysadmin', NOW(), 'sysadmin');  -- A388


-- ==========================================================================================
-- TBL_FLT_SCHDL — 항공스케줄 (4편)
-- FSCHDL001: ICN→NRT 기상 지연 (FLT_STTS_CD='DLYD', 이력 검증용)
-- ==========================================================================================

-- ① KE721 ICN→NRT — 기상 지연
INSERT INTO TBL_FLT_SCHDL
    (FLT_SCHDL_ID, ACFT_ID, ARLN_CD, FLT_NO, DPTRE_ARPT_CD, ARVL_ARPT_CD,
     EST_DPTRE_DT, EST_ARVL_DT, ACTL_DPTRE_DT, ACTL_ARVL_DT,
     FLT_STTS_CD, DLY_RSN_CD, DLY_RMRK,
     ECO_TOT_SEAT_CNT, BIZ_TOT_SEAT_CNT, FRST_TOT_SEAT_CNT,
     ECO_AVBL_SEAT_CNT, BIZ_AVBL_SEAT_CNT, FRST_AVBL_SEAT_CNT,
     DEL_YN, REG_DT, RGTR_ID, MDFCN_DT, MDFR_ID)
VALUES
    ('FSCHDL001', 'ACFT001', 'KE', 'KE721', 'ICN', 'NRT',
     '2026-07-01 09:00:00', '2026-07-01 11:30:00', NULL, NULL,
     'DLYD', 'WTHR', '기상악화로 인한 출발 지연',
     162, 12, 0,
     140, 10, 0,
     'N', NOW(), 'sysadmin', NOW(), 'sysadmin');

-- ② KE081 ICN→LAX
INSERT INTO TBL_FLT_SCHDL
    (FLT_SCHDL_ID, ACFT_ID, ARLN_CD, FLT_NO, DPTRE_ARPT_CD, ARVL_ARPT_CD,
     EST_DPTRE_DT, EST_ARVL_DT, ACTL_DPTRE_DT, ACTL_ARVL_DT,
     FLT_STTS_CD, DLY_RSN_CD, DLY_RMRK,
     ECO_TOT_SEAT_CNT, BIZ_TOT_SEAT_CNT, FRST_TOT_SEAT_CNT,
     ECO_AVBL_SEAT_CNT, BIZ_AVBL_SEAT_CNT, FRST_AVBL_SEAT_CNT,
     DEL_YN, REG_DT, RGTR_ID, MDFCN_DT, MDFR_ID)
VALUES
    ('FSCHDL002', 'ACFT002', 'KE', 'KE081', 'ICN', 'LAX',
     '2026-07-01 11:00:00', '2026-07-02 07:30:00', NULL, NULL,
     'SCHD', NULL, NULL,
     262, 52, 8,
     200, 40, 8,
     'N', NOW(), 'sysadmin', NOW(), 'sysadmin');

-- ③ KE657 ICN→BKK
INSERT INTO TBL_FLT_SCHDL
    (FLT_SCHDL_ID, ACFT_ID, ARLN_CD, FLT_NO, DPTRE_ARPT_CD, ARVL_ARPT_CD,
     EST_DPTRE_DT, EST_ARVL_DT, ACTL_DPTRE_DT, ACTL_ARVL_DT,
     FLT_STTS_CD, DLY_RSN_CD, DLY_RMRK,
     ECO_TOT_SEAT_CNT, BIZ_TOT_SEAT_CNT, FRST_TOT_SEAT_CNT,
     ECO_AVBL_SEAT_CNT, BIZ_AVBL_SEAT_CNT, FRST_AVBL_SEAT_CNT,
     DEL_YN, REG_DT, RGTR_ID, MDFCN_DT, MDFR_ID)
VALUES
    ('FSCHDL003', 'ACFT001', 'KE', 'KE657', 'ICN', 'BKK',
     '2026-07-02 13:30:00', '2026-07-02 17:50:00', NULL, NULL,
     'SCHD', NULL, NULL,
     162, 12, 0,
     155, 12, 0,
     'N', NOW(), 'sysadmin', NOW(), 'sysadmin');

-- ④ KE901 ICN→CDG (파리)
INSERT INTO TBL_FLT_SCHDL
    (FLT_SCHDL_ID, ACFT_ID, ARLN_CD, FLT_NO, DPTRE_ARPT_CD, ARVL_ARPT_CD,
     EST_DPTRE_DT, EST_ARVL_DT, ACTL_DPTRE_DT, ACTL_ARVL_DT,
     FLT_STTS_CD, DLY_RSN_CD, DLY_RMRK,
     ECO_TOT_SEAT_CNT, BIZ_TOT_SEAT_CNT, FRST_TOT_SEAT_CNT,
     ECO_AVBL_SEAT_CNT, BIZ_AVBL_SEAT_CNT, FRST_AVBL_SEAT_CNT,
     DEL_YN, REG_DT, RGTR_ID, MDFCN_DT, MDFR_ID)
VALUES
    ('FSCHDL004', 'ACFT003', 'KE', 'KE901', 'ICN', 'CDG',
     '2026-07-02 18:00:00', '2026-07-03 23:30:00', NULL, NULL,
     'SCHD', NULL, NULL,
     407, 94, 12,
     380, 80, 12,
     'N', NOW(), 'sysadmin', NOW(), 'sysadmin');


-- ==========================================================================================
-- TBL_FLT_SCHDL_HSTRY — 스케줄 변경이력 (2건: FSCHDL001 지연 시나리오)
-- FSHSTRY001: 최초 스케줄 등록 이력 (BFR_FLT_STTS_CD=NULL — 이전 상태 없음)
-- FSHSTRY002: 기상 지연 등록 이력 (SCHD → DLYD, 예상 시각 변경 없이 상태만 변경)
-- ==========================================================================================

-- 최초 등록 이력
INSERT INTO TBL_FLT_SCHDL_HSTRY
    (FLT_SCHDL_HSTRY_ID, FLT_SCHDL_ID, CHG_TP_CD,
     BFR_FLT_STTS_CD, AFT_FLT_STTS_CD,
     BFR_EST_DPTRE_DT, AFT_EST_DPTRE_DT,
     BFR_EST_ARVL_DT, AFT_EST_ARVL_DT,
     DLY_RSN_CD, RMRK, REG_DT, RGTR_ID)
VALUES
    ('FSHSTRY001', 'FSCHDL001', 'SCHDL_CHG',
     NULL, 'SCHD',
     NULL, '2026-07-01 09:00:00',
     NULL, '2026-07-01 11:30:00',
     NULL, '최초 스케줄 등록', '2026-06-01 10:00:00', 'sysadmin');

-- 지연 등록 이력 (SCHD → DLYD, 예상 시각 변경 없음 — 상태만 변경)
INSERT INTO TBL_FLT_SCHDL_HSTRY
    (FLT_SCHDL_HSTRY_ID, FLT_SCHDL_ID, CHG_TP_CD,
     BFR_FLT_STTS_CD, AFT_FLT_STTS_CD,
     BFR_EST_DPTRE_DT, AFT_EST_DPTRE_DT,
     BFR_EST_ARVL_DT, AFT_EST_ARVL_DT,
     DLY_RSN_CD, RMRK, REG_DT, RGTR_ID)
VALUES
    ('FSHSTRY002', 'FSCHDL001', 'DLY_REG',
     'SCHD', 'DLYD',
     '2026-07-01 09:00:00', '2026-07-01 09:00:00',
     '2026-07-01 11:30:00', '2026-07-01 11:30:00',
     'WTHR', '기상악화로 인한 지연 등록. 관제탑 기상 경보 발령', '2026-06-30 08:30:00', 'ops_user1');
