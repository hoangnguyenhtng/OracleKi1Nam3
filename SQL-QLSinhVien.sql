--TAO BANG DU LIEU 9 BANG
CREATE TABLE tblSinhVien (
  MSV NUMBER PRIMARY KEY,
  maLop VARCHAR2(10) NOT NULL,
  maChuongTrinhDaoTao VARCHAR2(10) NOT NULL,
  gioiTinh NUMBER(1) NOT NULL,
  namNhapHoc NUMBER NOT NULL,
  ngaySinh DATE NOT NULL,
  ten NVARCHAR2(50) NOT NULL,
  hoDem NVARCHAR2(50) NOT NULL,
  GPA NUMBER NOT NULL,
  CONSTRAINT fk_chuongtrinhdaotao_sv 
    FOREIGN KEY (maChuongTrinhDaoTao) 
    REFERENCES tblChuongTrinhDaoTao(maChuongTrinhDaoTao),
  CONSTRAINT fk_lop_sv 
    FOREIGN KEY (maLop) 
    REFERENCES tblLop(maLop)
);



ALTER TABLE tblSinhVien 
ADD email VARCHAR2(100);
ALTER TABLE tblSinhVien 
ADD dienThoai VARCHAR2(20);
ALTER TABLE tblSinhVien 
ADD  diaChi NVARCHAR2(100);
ALTER TABLE tblSinhVien 
ADD hoatDong NUMBER(1);

--tblDiem
CREATE TABLE tblDiem (
  MSV NUMBER NOT NULL,
  kyHoc NUMBER NOT NULL,
  diemGPA NUMBER(3, 2),
  diemRenLuyen NUMBER,
  CONSTRAINT pk_tblDiem PRIMARY KEY (MSV, kyHoc),
  CONSTRAINT fk_tblDiem_SinhVien FOREIGN KEY (MSV) REFERENCES tblSinhVien(MSV)
);


CREATE TABLE tblChuongTrinhDaoTao (
  maChuongTrinhDaoTao VARCHAR2(10) PRIMARY KEY,
  tenChuongTrinhDaoTao NVARCHAR2(100) NOT NULL,
  soTinChi NUMBER NOT NULL,
  namBatDau NUMBER NOT NULL 
);

CREATE TABLE tblLop (
  maLop VARCHAR2(10) PRIMARY KEY,
  tenLop NVARCHAR2(100) NOT NULL,
  nienKhoa VARCHAR2(5) NOT NULL,
  soSV NUMBER NOT NULL,
  maKhoa VARCHAR2(10) NOT NULL,
  maNhanVien NUMBER NOT NULL,
  CONSTRAINT fk_lop_khoa
    FOREIGN KEY (maKhoa) 
    REFERENCES tblKhoa(maKhoa),
    CONSTRAINT fk_lop_nhanvien
    FOREIGN KEY (maNhanVien) 
    REFERENCES tblNhanVien(maNhanVien)
);

CREATE TABLE tblKhoa (
  maKhoa VARCHAR2(10) PRIMARY KEY,
  tenKhoa NVARCHAR2(100) NOT NULL,
  ngayThanhLap DATE NOT NULL,
  maNhanVien NUMBER NOT NULL,
  
  CONSTRAINT fk_nhanvien_khoa
    FOREIGN KEY (maNhanVien) 
    REFERENCES tblNhanVien(maNhanVien)
);

CREATE TABLE tblNhanVien (
  maNhanVien NUMBER PRIMARY KEY,
  hoDem NVARCHAR2(50) NOT NULL,
  ten NVARCHAR2(50) NOT NULL, 
  chucVu NVARCHAR2(100) NOT NULL,
  ngaySinh DATE NOT NULL,
  gioiTinh NUMBER(1) NOT NULL, 
  namCongTac NUMBER NOT NULL
);

CREATE TABLE tblBoMon (
  maBoMon NUMBER PRIMARY KEY,
  tenBoMon NVARCHAR2(50) NOT NULL,
  moTa NVARCHAR2(500),
  maNhanVien NUMBER NOT NULL,
  CONSTRAINT fk_nhanvien_bomon 
    FOREIGN KEY (maNhanVien) 
    REFERENCES tblNhanVien(maNhanVien)
);

CREATE TABLE tblMonHoc (
  maMonHoc NUMBER PRIMARY KEY, 
  tenMonHoc NVARCHAR2(100) NOT NULL,
  maBoMon NUMBER NOT NULL,
  soTinChi NUMBER NOT NULL,
  moTa NVARCHAR2(500),
  maChuongTrinhDaoTao VARCHAR2(10) NOT NULL,
  
  CONSTRAINT fk_mabomon_monhoc 
    FOREIGN KEY (maBoMon)
    REFERENCES tblBoMon(maBoMon),
  
  CONSTRAINT fk_machuongtrinhdaotao_monhoc
    FOREIGN KEY (maChuongTrinhDaoTao)
    REFERENCES tblChuongTrinhDaoTao(maChuongTrinhDaoTao)
);

    
CREATE TABLE tblLopHocPhan (
  maLopHocPhan NUMBER PRIMARY KEY,
  tenLopHocPhan NVARCHAR2(100) NOT NULL,
  soLuongSinhVien NUMBER NOT NULL,
  moTa NVARCHAR2(500),
  hocKy NUMBER NOT NULL,
  namHoc NUMBER NOT NULL,
  maMonHoc NUMBER NOT NULL,
  maNhanVien NUMBER NOT NULL,
  
  CONSTRAINT fk_monhoc_lop 
    FOREIGN KEY(maMonHoc) 
    REFERENCES tblMonHoc(maMonHoc),

  CONSTRAINT fk_nhanvien_lop
    FOREIGN KEY(maNhanVien)
    REFERENCES tblNhanVien(maNhanVien)  
);

CREATE TABLE tblSinhVienTGLop (

  maLopHocPhan NUMBER NOT NULL,
  MSV NUMBER NOT NULL,
  
  diemQuaTrinh NUMBER,
  diemThi NUMBER,

  CONSTRAINT fk_malophocphan
    FOREIGN KEY(maLopHocPhan)
    REFERENCES tblLopHocPhan(maLopHocPhan),

  CONSTRAINT fk_masinhvien
    FOREIGN KEY(MSV) 
    REFERENCES tblSinhVien(MSV)
);


-- THEM CAC RANG BUOC
--tblSinhVien
--MSV co 9 chu so

ALTER TABLE tblSinhVien
ADD CONSTRAINT chk_msv CHECK (LENGTH(MSV) = 9);

--Ngay sinh phai truoc ngay hom nay
CREATE OR REPLACE TRIGGER ngaySinh_tblSinhVien
BEFORE INSERT ON tblSinhVien
FOR EACH ROW
DECLARE
BEGIN
  IF :NEW.ngaySinh >= SYSDATE THEN
    RAISE_APPLICATION_ERROR(-20001, 'Ngay sinh khong hop le');
  END IF;
END;

--namNhapHoc phai nho hon hoac bang nam nay và khong duoc nho hon qua 20 nam
CREATE OR REPLACE TRIGGER namNhapHoc_tblSinhVien
BEFORE INSERT ON tblSinhVien
FOR EACH ROW
DECLARE
  v_current_year NUMBER;
BEGIN
  -- Lay nam hien tai
  SELECT EXTRACT(YEAR FROM SYSDATE) INTO v_current_year FROM DUAL;

  -- Kiem tra dieu kien nam nhap hoc
  IF :NEW.namNhapHoc > v_current_year OR :NEW.namNhapHoc < v_current_year - 20 THEN
    RAISE_APPLICATION_ERROR(-20002, 'Nam nhap hoc phai tu ' || v_current_year - 20 || ' den ' || v_current_year || '.');
  END IF;
END;

--GPA nam trong khoang 0-4
ALTER TABLE tblSinhVien
  ADD CONSTRAINT chk_gpa CHECK (
    GPA >= 0 AND GPA <= 4
  );
--Ma Lop phai la duy nhat
ALTER TABLE tblSinhVien
  ADD CONSTRAINT uni_malop UNIQUE (maLop);

--tblLop
--si so phai lon hon bang 5 va nho hon bang 200
ALTER TABLE tblLop
ADD CONSTRAINT chk_soSV
CHECK (soSV >= 5 AND soSV <= 200);

--tblMonHoc
--so tin chi can gioi han
ALTER TABLE tblMonHoc
ADD CONSTRAINT chk_soTinChi
CHECK (soTinChi >= 1 AND soTinChi <= 10);

--unique 
ALTER TABLE tblMonHoc
ADD CONSTRAINT uk_tenMonHoc
UNIQUE (tenMonHoc);

--tblNhanVien
CREATE OR REPLACE TRIGGER namCongTac_tblNhanVien
BEFORE INSERT ON tblNhanVien
FOR EACH ROW
DECLARE
  v_current_year NUMBER;
BEGIN
  -- Lay nam hoc hien tai
  SELECT EXTRACT(YEAR FROM SYSDATE) INTO v_current_year FROM DUAL;

  -- Kiem tra dieu kien nam cong tac
  IF :NEW.namCongTac > v_current_year THEN
    RAISE_APPLICATION_ERROR(-20003, 'Nam cong tac khong hop li');
  END IF;
END;

--tblSinhVienTGLop
-- Thêm ràng buoc CHECK cho cot diemQuaTrinh
ALTER TABLE tblSinhVienTGLop
ADD CONSTRAINT chk_diemQuaTrinh CHECK (diemQuaTrinh >= 0 AND diemQuaTrinh <= 10);

-- Thêm ràng buoc CHECK cho cot diemThi
ALTER TABLE tblSinhVienTGLop
ADD CONSTRAINT chk_diemThi CHECK (diemThi >= 0 AND diemThi <= 10);


--INSERT DU LIEU
--tblNhanVien
INSERT INTO tblNhanVien (maNhanVien, hoDem, ten, chucVu, ngaySinh, gioiTinh, namCongTac)
VALUES 
(1, 'Tran Van', 'An', 'Giang vien', TO_DATE('01-01-1980', 'DD-MM-YYYY'), 1, 2010);
INSERT INTO tblNhanVien (maNhanVien, hoDem, ten, chucVu, ngaySinh, gioiTinh, namCongTac)
VALUES 
(2, 'Tran Trong', 'Nghia', 'Giang vien', TO_DATE('06-06-1983', 'DD-MM-YYYY'), 1, 2011);
INSERT INTO tblNhanVien (maNhanVien, hoDem, ten, chucVu, ngaySinh, gioiTinh, namCongTac)
VALUES 
(3, 'Vu Duc', 'Hung', 'Giang vien', TO_DATE('04-06-1985', 'DD-MM-YYYY'), 1, 2013);
INSERT INTO tblNhanVien (maNhanVien, hoDem, ten, chucVu, ngaySinh, gioiTinh, namCongTac)
VALUES 
(4, 'Vu Van', 'Viet', 'Nhan vien phong dao tao', TO_DATE('09-04-1988', 'DD-MM-YYYY'), 1, 2013);
INSERT INTO tblNhanVien (maNhanVien, hoDem, ten, chucVu, ngaySinh, gioiTinh, namCongTac)
VALUES 
(11, 'To Thi', 'Lan', 'Giang vien', TO_DATE('12-06-1990', 'DD-MM-YYYY'), 0, 2018);
INSERT INTO tblNhanVien (maNhanVien, hoDem, ten, chucVu, ngaySinh, gioiTinh, namCongTac)
VALUES 
(5, 'Tran Quynh', 'Nhu', 'Nhan vien ke toan', TO_DATE('12-09-1989', 'DD-MM-YYYY'), 1, 2020);
INSERT INTO tblNhanVien (maNhanVien, hoDem, ten, chucVu, ngaySinh, gioiTinh, namCongTac)
VALUES 
(6, 'Vu Viet', 'Anh', 'Giang vien', TO_DATE('04-04-1988', 'DD-MM-YYYY'), 1, 2013);
INSERT INTO tblNhanVien (maNhanVien, hoDem, ten, chucVu, ngaySinh, gioiTinh, namCongTac)
VALUES 
(7, 'Nguyen Tien', 'Anh', 'Nhan vien thu vien', TO_DATE('08-05-1989', 'DD-MM-YYYY'), 1, 2019);
INSERT INTO tblNhanVien (maNhanVien, hoDem, ten, chucVu, ngaySinh, gioiTinh, namCongTac)
VALUES 
(8, 'Nguyen Thi Tuyet', 'Trinh', 'Giang vien', TO_DATE('04-06-1998', 'DD-MM-YYYY'), 0, 2022);
INSERT INTO tblNhanVien (maNhanVien, hoDem, ten, chucVu, ngaySinh, gioiTinh, namCongTac)
VALUES 
(9, 'Phung Tien', 'Viet', 'Nhan vien phong dao tao', TO_DATE('05-06-1989', 'DD-MM-YYYY'), 1, 2017);
INSERT INTO tblNhanVien (maNhanVien, hoDem, ten, chucVu, ngaySinh, gioiTinh, namCongTac)
VALUES 
(10, 'Nguyen Thi', 'Tien', 'Giang vien', TO_DATE('03-06-1990', 'DD-MM-YYYY'), 0, 2022);
INSERT INTO tblNhanVien (maNhanVien, hoDem, ten, chucVu, ngaySinh, gioiTinh, namCongTac)
VALUES 
(12, 'Nguyen Van', 'Tien', 'Giang vien', TO_DATE('03-06-1990', 'DD-MM-YYYY'), 0, 2010);
INSERT INTO tblNhanVien (maNhanVien, hoDem, ten, chucVu, ngaySinh, gioiTinh, namCongTac)
VALUES 
(13, 'Nguyen Thi', 'Ngu', 'Giang vien', TO_DATE('03-06-1990', 'DD-MM-YYYY'), 0, 2022);
INSERT INTO tblNhanVien (maNhanVien, hoDem, ten, chucVu, ngaySinh, gioiTinh, namCongTac)
VALUES 
(14, 'Nguyen Tran Trong', 'Dung', 'Giang vien', TO_DATE('03-06-1989', 'DD-MM-YYYY'), 1, 2020);
INSERT INTO tblNhanVien (maNhanVien, hoDem, ten, chucVu, ngaySinh, gioiTinh, namCongTac)
VALUES 
(15, 'Tran Thanh', 'Tien', 'Giang vien', TO_DATE('03-06-1980', 'DD-MM-YYYY'), 1, 2019);
INSERT INTO tblNhanVien (maNhanVien, hoDem, ten, chucVu, ngaySinh, gioiTinh, namCongTac)
VALUES 
(16, 'Vu Thi', 'Linh', 'Giang vien', TO_DATE('12-12-1993', 'DD-MM-YYYY'), 0, 2020);
INSERT INTO tblNhanVien (maNhanVien, hoDem, ten, chucVu, ngaySinh, gioiTinh, namCongTac)
VALUES 
(17, 'Tran Kim', 'Anh', 'Giang vien', TO_DATE('09-10-1990', 'DD-MM-YYYY'), 0, 2020);
INSERT INTO tblNhanVien (maNhanVien, hoDem, ten, chucVu, ngaySinh, gioiTinh, namCongTac)
VALUES 
(18, 'Nguyen Thi', 'Chau', 'Giang vien', TO_DATE('03-06-1996', 'DD-MM-YYYY'), 0, 2019);



--tblBoMon 
-- Thêm d? li?u m?u cho b?ng tblBoMon
INSERT INTO tblBoMon (maBoMon, tenBoMon, moTa, maNhanVien)
VALUES (1, 'Toan va xac suat', 'Bo mon nay bao gom cac mon hoc lien quan den toan va xac suat. La bo mon nen tang, co ban nhat ma moi sinh vien GTVT can hoc va nam vung', 6);

INSERT INTO tblBoMon (maBoMon, tenBoMon, moTa, maNhanVien)
VALUES (2, 'Tinh ben cua cong trinh', 'Bo mon nay bao gom cac mon hoc lien quan tinh toan suc ben cua vat lieu va cong trinh xay dung. La bo mon nen tang, co ban nhat ma moi sinh vien khoa Cong trinh can hoc va nam vung', 3);

INSERT INTO tblBoMon (maBoMon, tenBoMon, moTa, maNhanVien)
VALUES (3, 'Vat ly, Hoa hoc va Khoa hoc tu nhien', 'Bo mon nay bao gom cac mon hoc lien quan den vat ly va hoa hoc', 1);

INSERT INTO tblBoMon (maBoMon, tenBoMon, moTa, maNhanVien)
VALUES (4, 'Web va ung dung web', 'Bo mon nay bao gom cac mon hoc lien quan den xay dung website. La bo mon nen tang, co ban nhat ma moi sinh vien khoa CNTT can hoc va nam vung', 11);

INSERT INTO tblBoMon (maBoMon, tenBoMon, moTa, maNhanVien)
VALUES (5, 'Khoa hoc may tinh', 'Bo mon nay bao gom cac mon hoc lien quan den cau truc va xu ly cac van de lien quan den may tinh và KHMT. La bo mon nen tang, co ban nhat ma moi sinh vien khoa CNTT can hoc va nam vung', 2);

--tblKhoa
INSERT INTO tblKhoa (maKhoa, tenKhoa, ngayThanhLap, maNhanVien)
VALUES 
('K001', 'Khoa Công ngh? thông tin', TO_DATE('01-01-1990', 'DD-MM-YYYY'), 2);
INSERT INTO tblKhoa (maKhoa, tenKhoa, ngayThanhLap, maNhanVien)
VALUES 
('K002', 'Khoa Công trình', TO_DATE('15-05-1995', 'DD-MM-YYYY'), 3);
INSERT INTO tblKhoa (maKhoa, tenKhoa, ngayThanhLap, maNhanVien)
VALUES 
('K003', 'Khoa Kinh doanh và Qu?n tr?', TO_DATE('10-09-1998', 'DD-MM-YYYY'), 11);
INSERT INTO tblKhoa (maKhoa, tenKhoa, ngayThanhLap, maNhanVien)
VALUES 
('K004', 'Khoa Kinh t? xây d?ng', TO_DATE('20-02-2000', 'DD-MM-YYYY'), 8);
INSERT INTO tblKhoa (maKhoa, tenKhoa, ngayThanhLap, maNhanVien)
VALUES 
('K005', 'Khoa C? khí', TO_DATE('05-03-1992', 'DD-MM-YYYY'), 16);

--2 3 11 8 16
--tblLop
INSERT INTO tblLop (maLop, tenLop, nienKhoa, soSV, maKhoa, maNhanVien)
VALUES 
('CNTT1', 'CNTT1-K62', '20-24', 71, 'K001', 2);
INSERT INTO tblLop (maLop, tenLop, nienKhoa, soSV, maKhoa, maNhanVien)
VALUES 
('CNTT2', 'CNTT2-K62', '20-24', 67, 'K001', 6);
INSERT INTO tblLop (maLop, tenLop, nienKhoa, soSV, maKhoa, maNhanVien)
VALUES 
('CNTT3', 'CNTT1-K63', '21-25', 60, 'K001', 2);
INSERT INTO tblLop (maLop, tenLop, nienKhoa, soSV, maKhoa, maNhanVien)
VALUES 
('CNTT4', 'CNTT2-K63', '21-25', 67, 'K001', 6);
INSERT INTO tblLop (maLop, tenLop, nienKhoa, soSV, maKhoa, maNhanVien)
VALUES 
('CNTT5', 'KHMT-K64', '22-26', 73, 'K001', 12);
INSERT INTO tblLop (maLop, tenLop, nienKhoa, soSV, maKhoa, maNhanVien)
VALUES 
('CNTT6', 'CNTT1-K64', '22-26', 69, 'K001', 12);
INSERT INTO tblLop (maLop, tenLop, nienKhoa, soSV, maKhoa, maNhanVien)
VALUES 
('KTXD1', 'KTXD1-K62', '20-24', 70, 'K002', 3);
INSERT INTO tblLop (maLop, tenLop, nienKhoa, soSV, maKhoa, maNhanVien)
VALUES 
('KTXD2', 'KTXD2-K62', '20-24', 72, 'K002', 3);
INSERT INTO tblLop (maLop, tenLop, nienKhoa, soSV, maKhoa, maNhanVien)
VALUES 
('CT1', 'CT1-K62', '20-24', 67, 'K002', 16);
INSERT INTO tblLop (maLop, tenLop, nienKhoa, soSV, maKhoa, maNhanVien)
VALUES 
('CT2', 'CT2-K62', '20-24', 75, 'K002', 16);
INSERT INTO tblLop (maLop, tenLop, nienKhoa, soSV, maKhoa, maNhanVien)
VALUES 
('CK1', 'CK1-K62', '20-24', 74, 'K005', 17);
INSERT INTO tblLop (maLop, tenLop, nienKhoa, soSV, maKhoa, maNhanVien)
VALUES 
('CK2', 'CK1-K62', '20-24', 74, 'K005', 18);
INSERT INTO tblLop (maLop, tenLop, nienKhoa, soSV, maKhoa, maNhanVien)
VALUES 
('CK3', 'CK1-K63', '21-25', 78, 'K005', 17);
INSERT INTO tblLop (maLop, tenLop, nienKhoa, soSV, maKhoa, maNhanVien)
VALUES 
('CK4', 'CK2-K63', '20-24', 74, 'K005', 18);

--tblMonHoc
INSERT INTO tblMonHoc (maMonHoc, tenMonHoc, maBoMon, soTinChi, moTa, maChuongTrinhDaoTao)
VALUES 
(1, 'Toán cao c?p', 1, 3, 'Môn h?c v? toán h?c nâng cao.', 'CT');
INSERT INTO tblMonHoc (maMonHoc, tenMonHoc, maBoMon, soTinChi, moTa, maChuongTrinhDaoTao)
VALUES 
(2, 'Toán cao c?p CNTT', 1, 3, 'Môn h?c v? toán h?c nâng cao.', 'CNTT');
INSERT INTO tblMonHoc (maMonHoc, tenMonHoc, maBoMon, soTinChi, moTa, maChuongTrinhDaoTao)
VALUES 
(3, 'Toán cao c?p xây d?ng', 1, 3, 'Môn h?c v? toán h?c nâng cao.', 'KTXD');
INSERT INTO tblMonHoc (maMonHoc, tenMonHoc, maBoMon, soTinChi, moTa, maChuongTrinhDaoTao)
VALUES 
(4, 'Toán cao c?p KHMT', 1, 3, 'Môn h?c v? toán h?c nâng cao.', 'KHMT');
INSERT INTO tblMonHoc (maMonHoc, tenMonHoc, maBoMon, soTinChi, moTa, maChuongTrinhDaoTao)
VALUES 
(5, 'V?t lý CT', 1, 3, 'Môn h?c v? toán h?c nâng cao.', 'CT');
INSERT INTO tblMonHoc (maMonHoc, tenMonHoc, maBoMon, soTinChi, moTa, maChuongTrinhDaoTao)
VALUES 
(6, 'V?t lý CNTT', 1, 3, 'Môn h?c v? toán h?c nâng cao.', 'CNTT');
INSERT INTO tblMonHoc (maMonHoc, tenMonHoc, maBoMon, soTinChi, moTa, maChuongTrinhDaoTao)
VALUES 
(7, 'V?t lý KTXD', 1, 3, 'Môn h?c v? toán h?c nâng cao.', 'KTXD');
INSERT INTO tblMonHoc (maMonHoc, tenMonHoc, maBoMon, soTinChi, moTa, maChuongTrinhDaoTao)
VALUES 
(8, 'V?t lý KHMT', 1, 3, 'Môn h?c v? toán h?c nâng cao.', 'KHMT');
INSERT INTO tblMonHoc (maMonHoc, tenMonHoc, maBoMon, soTinChi, moTa, maChuongTrinhDaoTao)
VALUES 
(9, '?? b?n công trình', 1, 2, 'Môn h?c v? tính b?n c?a v?t li?u công trình nâng cao nâng cao.', 'CT');
INSERT INTO tblMonHoc (maMonHoc, tenMonHoc, maBoMon, soTinChi, moTa, maChuongTrinhDaoTao)
VALUES 
(10, 'L?p trình web CNTT', 1, 4, 'Môn h?c v? l?p trình front và back end nâng cao.', 'CNTT');
INSERT INTO tblMonHoc (maMonHoc, tenMonHoc, maBoMon, soTinChi, moTa, maChuongTrinhDaoTao)
VALUES 
(11, 'L?p trình web KHMT', 1, 4, 'Môn h?c v? toán h?c nâng cao.', 'KHMT');
INSERT INTO tblMonHoc (maMonHoc, tenMonHoc, maBoMon, soTinChi, moTa, maChuongTrinhDaoTao)
VALUES 
(12, 'C?u trúc và t? ch?c máy tính', 3, 4, 'Môn h?c v? toán h?c nâng cao.', 'KHMT');

--tblChuongTrinhDaoTao
INSERT INTO tblChuongTrinhDaoTao (maChuongTrinhDaoTao, tenChuongTrinhDaoTao, soTinChi, namBatDau)
VALUES 
('CNTT', 'Ch??ng trình Công ngh? thông tin', 150, 2003);
INSERT INTO tblChuongTrinhDaoTao (maChuongTrinhDaoTao, tenChuongTrinhDaoTao, soTinChi, namBatDau)
VALUES 
('CT', 'Ch??ng trình Công trình giao thông', 123, 1990);
INSERT INTO tblChuongTrinhDaoTao (maChuongTrinhDaoTao, tenChuongTrinhDaoTao, soTinChi, namBatDau)
VALUES 
('KTXD', 'Ch??ng trình Kinh t? xây d?ng', 144, 1989);
INSERT INTO tblChuongTrinhDaoTao (maChuongTrinhDaoTao, tenChuongTrinhDaoTao, soTinChi, namBatDau)
VALUES 
('KHMT', 'Ch??ng trình Khoa h?c máy tính', 180, 2008);
INSERT INTO tblChuongTrinhDaoTao (maChuongTrinhDaoTao, tenChuongTrinhDaoTao, soTinChi, namBatDau)
VALUES 
('CK', 'Ch??ng trình C? khí', 120, 1990);

--tblLopHocPhan
select * from tblLopHocPhan;
DELETE FROM tblLopHocPhan;

INSERT INTO tblLopHocPhan (maLopHocPhan, tenLopHocPhan, soLuongSinhVien, moTa, hocKy, namHoc, maMonHoc, maNhanVien)
VALUES 
(1, 'N01-TCC', 50, 'L?p h?c ph?n môn Toán Cao c?p', 1, 2022, 1, 6);
INSERT INTO tblLopHocPhan (maLopHocPhan, tenLopHocPhan, soLuongSinhVien, moTa, hocKy, namHoc, maMonHoc, maNhanVien)
VALUES 
(2, 'N02-TCC', 50, 'L?p h?c ph?n môn Toán Cao c?p CNTT', 1, 2022, 1, 6);
INSERT INTO tblLopHocPhan (maLopHocPhan, tenLopHocPhan, soLuongSinhVien, moTa, hocKy, namHoc, maMonHoc, maNhanVien)
VALUES 
(3, 'N03-TCC', 50, 'L?p h?c ph?n Toán cao c?p KHMT', 2, 2022, 1, 18);
INSERT INTO tblLopHocPhan (maLopHocPhan, tenLopHocPhan, soLuongSinhVien, moTa, hocKy, namHoc, maMonHoc, maNhanVien)
VALUES 
(4, 'V01-VL', 50, 'V?t lý và ?ng d?ng Công trình', 2, 2022, 5, 16);
INSERT INTO tblLopHocPhan (maLopHocPhan, tenLopHocPhan, soLuongSinhVien, moTa, hocKy, namHoc, maMonHoc, maNhanVien)
VALUES 
(5, 'V02-VL', 60, 'V?t lý và ?ng d?ng CNTT', 2, 2022, 6, 16);
INSERT INTO tblLopHocPhan (maLopHocPhan, tenLopHocPhan, soLuongSinhVien, moTa, hocKy, namHoc, maMonHoc, maNhanVien)
VALUES 
(6, 'V03-VL', 71, 'V?t lý và ?ng d?ng KTXD', 2, 2022, 7, 17);
INSERT INTO tblLopHocPhan (maLopHocPhan, tenLopHocPhan, soLuongSinhVien, moTa, hocKy, namHoc, maMonHoc, maNhanVien)
VALUES 
(7, 'V04-VL', 58, 'V?t lý và ?ng d?ng KHMT', 2, 2022, 8, 18);
INSERT INTO tblLopHocPhan (maLopHocPhan, tenLopHocPhan, soLuongSinhVien, moTa, hocKy, namHoc, maMonHoc, maNhanVien)
VALUES 
(8, 'B01-SBCT', 59, 'S?c b?n c?a v?t li?u Công trình', 1, 2023, 9, 8);
INSERT INTO tblLopHocPhan (maLopHocPhan, tenLopHocPhan, soLuongSinhVien, moTa, hocKy, namHoc, maMonHoc, maNhanVien)
VALUES 
(9, 'B02-SBCT', 69, 'S?c b?n c?a v?t li?u Công trình', 1, 2023, 9, 8);
INSERT INTO tblLopHocPhan (maLopHocPhan, tenLopHocPhan, soLuongSinhVien, moTa, hocKy, namHoc, maMonHoc, maNhanVien)
VALUES 
(10, 'CT01-CTTCMT', 67, 'C?u trúc và t? ch?c máy tính', 2, 2023, 12, 10);
INSERT INTO tblLopHocPhan (maLopHocPhan, tenLopHocPhan, soLuongSinhVien, moTa, hocKy, namHoc, maMonHoc, maNhanVien)
VALUES 
(11, 'CT02-CTTCMT', 69, 'C?u trúc và t? ch?c máy tính KHMT', 2, 2023, 12, 11);
INSERT INTO tblLopHocPhan (maLopHocPhan, tenLopHocPhan, soLuongSinhVien, moTa, hocKy, namHoc, maMonHoc, maNhanVien)
VALUES 
(12, 'CT03-CTTCMT', 67, 'C?u trúc và t? ch?c máy tính KHMT', 2, 2023, 12, 10);
INSERT INTO tblLopHocPhan (maLopHocPhan, tenLopHocPhan, soLuongSinhVien, moTa, hocKy, namHoc, maMonHoc, maNhanVien)
VALUES 
(13, 'W01-LTWEB', 69, 'L?p trình Web kh?i chuyên tin', 1, 2023, 10, 13);
INSERT INTO tblLopHocPhan (maLopHocPhan, tenLopHocPhan, soLuongSinhVien, moTa, hocKy, namHoc, maMonHoc, maNhanVien)
VALUES 
(14, 'W02-LTWEB', 72, 'L?p trình Web kh?i không chuyên tin', 1, 2023, 11, 14);

select * from tblSinhVien where maLop = 'CNTT1';
--tblSinhVien
--cntt1 batdau
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(211123456, 'CNTT1', 'CNTT', 1, 2020, TO_DATE('17-01-2003', 'DD-MM-YYYY'), 'Nguy?n V?n', 'An', 3.5);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(211223452, 'CNTT1', 'CNTT', 1, 2020, TO_DATE('13-11-2003', 'DD-MM-YYYY'), 'V? Thành', 'Trung', 3.7);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(211213123, 'CNTT1', 'CNTT', 1, 2020, TO_DATE('23-01-2003', 'DD-MM-YYYY'), 'Tr?n Tr?ng', 'Quy?t', 3.1);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(211234456, 'CNTT1', 'CNTT', 1, 2020, TO_DATE('11-11-2003', 'DD-MM-YYYY'), 'Hu?nh V?n', 'Trung', 3.2);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(211657587, 'CNTT1', 'CNTT', 0, 2020, TO_DATE('14-12-2003', 'DD-MM-YYYY'), 'Tr?n Kim', 'Anh', 3.4);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(211987646, 'CNTT1', 'CNTT', 0, 2020, TO_DATE('12-09-2003', 'DD-MM-YYYY'), 'Tr?n Thùy', 'Dung', 3.8);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(211987453, 'CNTT1', 'CNTT', 0, 2020, TO_DATE('19-09-2003', 'DD-MM-YYYY'), 'Tr?n Th?', 'Lan', 2.9);
--
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(211445456, 'CNTT1', 'CNTT', 1, 2020, TO_DATE('11-02-2002', 'DD-MM-YYYY'), 'Tr?n Tr?ng', 'Ân', 2.3);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(211222452, 'CNTT1', 'CNTT', 1, 2020, TO_DATE('07-10-2003', 'DD-MM-YYYY'), 'Tr?n V?n', 'Minh', 3.4);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(211333123, 'CNTT1', 'CNTT', 0, 2020, TO_DATE('12-01-2003', 'DD-MM-YYYY'), 'Tr?n Thu', 'Trang', 3.1);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(211444456, 'CNTT1', 'CNTT', 1, 2020, TO_DATE('21-10-2003', 'DD-MM-YYYY'), 'Nguy?n H?u', 'Ngh?a', 3.1);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(211555587, 'CNTT1', 'CNTT', 0, 2020, TO_DATE('09-12-2003', 'DD-MM-YYYY'), 'D??ng Qu?c', 'Anh', 3.0);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(211777646, 'CNTT1', 'CNTT', 0, 2020, TO_DATE('15-09-2003', 'DD-MM-YYYY'), 'Tr?n Th? M?', 'Dung', 2.8);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(211666653, 'CNTT1', 'CNTT', 0, 2020, TO_DATE('16-09-2003', 'DD-MM-YYYY'), 'V? Th? Ph??ng', 'Anh', 2.9);

INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(212445412, 'CNTT1', 'CNTT', 1, 2020, TO_DATE('17-02-2003', 'DD-MM-YYYY'), 'V? ?ình', 'An', 3.5);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(212222413, 'CNTT1', 'CNTT', 1, 2020, TO_DATE('13-10-2003', 'DD-MM-YYYY'), 'Tr?n Thành', 'Minh', 3.4);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(212333114, 'CNTT1', 'CNTT', 0, 2020, TO_DATE('23-11-2003', 'DD-MM-YYYY'), 'Tr?n Thu', 'Trang', 3.1);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(212444415, 'CNTT1', 'CNTT', 1, 2020, TO_DATE('21-12-2003', 'DD-MM-YYYY'), 'Nguy?n H?u', 'Trung', 3.2);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(212555516, 'CNTT1', 'CNTT', 0, 2020, TO_DATE('31-12-2003', 'DD-MM-YYYY'), 'V? Minh', 'Anh', 3.0);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(212777617, 'CNTT1', 'CNTT', 0, 2020, TO_DATE('05-09-2003', 'DD-MM-YYYY'), 'Tr?n Nguy?n Th?', 'Dung', 2.8);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(211666418, 'CNTT1', 'CNTT', 0, 2020, TO_DATE('06-09-2003', 'DD-MM-YYYY'), 'V? Th? Lan', 'Anh', 2.9);

INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(212455412, 'CNTT1', 'CNTT', 1, 2020, TO_DATE('17-02-2003', 'DD-MM-YYYY'), 'Hoàng ?ình', 'An', 3.5);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(212562413, 'CNTT1', 'CNTT', 1, 2020, TO_DATE('13-10-2003', 'DD-MM-YYYY'), 'Hoàng Thành', 'Minh', 3.4);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(212433914, 'CNTT1', 'CNTT', 0, 2020, TO_DATE('23-11-2003', 'DD-MM-YYYY'), 'Nguy?n Thu', 'Trang', 3.1);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(212344415, 'CNTT1', 'CNTT', 1, 2020, TO_DATE('21-12-2003', 'DD-MM-YYYY'), 'Tr?n H?u', 'Trung', 3.2);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(212355516, 'CNTT1', 'CNTT', 0, 2020, TO_DATE('31-12-2003', 'DD-MM-YYYY'), 'Hoàng Minh', 'Anh', 3.0);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(212377617, 'CNTT1', 'CNTT', 0, 2020, TO_DATE('05-09-2003', 'DD-MM-YYYY'), 'V? Nguy?n Th?', 'Dung', 2.8);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(211366418, 'CNTT1', 'CNTT', 0, 2020, TO_DATE('06-09-2003', 'DD-MM-YYYY'), 'Hoàng Th? Lan', 'Anh', 2.9);

INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(213455412, 'CNTT1', 'CNTT', 1, 2020, TO_DATE('17-02-2003', 'DD-MM-YYYY'), 'Hoàng ?ình', 'D?ng', 3.5);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(213562413, 'CNTT1', 'CNTT', 1, 2020, TO_DATE('13-10-2003', 'DD-MM-YYYY'), 'Hoàng Thành', 'Long', 3.4);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(213433914, 'CNTT1', 'CNTT', 0, 2020, TO_DATE('23-11-2003', 'DD-MM-YYYY'), 'Nguy?n Thu', 'Th?y', 3.1);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(213344415, 'CNTT1', 'CNTT', 1, 2020, TO_DATE('21-12-2003', 'DD-MM-YYYY'), 'Tr?n H?u', 'V?', 3.2);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(213355516, 'CNTT1', 'CNTT', 0, 2020, TO_DATE('31-12-2003', 'DD-MM-YYYY'), 'Hoàng Minh', 'An', 3.0);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(213377617, 'CNTT1', 'CNTT', 0, 2020, TO_DATE('05-09-2003', 'DD-MM-YYYY'), 'V? Nguy?n Th?', 'Tuy?t', 2.8);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(213366418, 'CNTT1', 'CNTT', 0, 2020, TO_DATE('06-09-2003', 'DD-MM-YYYY'), 'Hoàng Th? Lan', 'H??ng', 2.9);

INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(214455412, 'CNTT1', 'CNTT', 1, 2020, TO_DATE('17-02-2003', 'DD-MM-YYYY'), 'Hoàng ?ình', 'D?ng', 3.5);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(214562413, 'CNTT1', 'CNTT', 1, 2020, TO_DATE('13-10-2003', 'DD-MM-YYYY'), 'Hoàng Thành', 'Long', 3.4);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(214433914, 'CNTT1', 'CNTT', 0, 2020, TO_DATE('23-11-2003', 'DD-MM-YYYY'), 'Nguy?n Thu', 'Th?y', 3.1);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(214344415, 'CNTT1', 'CNTT', 1, 2020, TO_DATE('21-12-2003', 'DD-MM-YYYY'), 'Tr?n H?u', 'V?', 3.2);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(214355516, 'CNTT1', 'CNTT', 0, 2020, TO_DATE('31-12-2003', 'DD-MM-YYYY'), 'Hoàng Tu?n', 'Minh', 3.0);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(214377617, 'CNTT1', 'CNTT', 0, 2020, TO_DATE('05-09-2003', 'DD-MM-YYYY'), 'V? Th?', 'Ánh', 2.8);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(214366418, 'CNTT1', 'CNTT', 0, 2020, TO_DATE('06-09-2003', 'DD-MM-YYYY'), 'Hoàng Th? Tuy?t', 'Trinh', 2.9);

INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(215455412, 'CNTT1', 'CNTT', 1, 2020, TO_DATE('17-02-2003', 'DD-MM-YYYY'), 'Hoàng ?ình', 'D?ng', 3.5);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(215562413, 'CNTT1', 'CNTT', 1, 2020, TO_DATE('13-10-2003', 'DD-MM-YYYY'), 'Hoàng Thành', 'Long', 3.4);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(215433914, 'CNTT1', 'CNTT', 0, 2020, TO_DATE('23-11-2003', 'DD-MM-YYYY'), 'Nguy?n Thu', 'Th?y', 3.1);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(215344415, 'CNTT1', 'CNTT', 1, 2020, TO_DATE('21-12-2003', 'DD-MM-YYYY'), 'Tr?n H?u', 'V?', 3.2);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(215355516, 'CNTT1', 'CNTT', 0, 2020, TO_DATE('31-12-2003', 'DD-MM-YYYY'), 'Hoàng Tu?n', 'Minh', 3.0);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(215377617, 'CNTT1', 'CNTT', 0, 2020, TO_DATE('05-09-2003', 'DD-MM-YYYY'), 'V? Th?', 'Ánh', 2.8);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(215366418, 'CNTT1', 'CNTT', 0, 2020, TO_DATE('06-09-2003', 'DD-MM-YYYY'), 'Hoàng Th? Tuy?t', 'Trinh', 2.9);

--cntt ket thuc
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(211123579, 'CNTT2', 'CNTT', 1, 2020, TO_DATE('19-01-2003', 'DD-MM-YYYY'), 'Nguy?n V?n', 'Sinh', 2.8);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(211223589, 'CNTT2', 'CNTT', 1, 2020, TO_DATE('13-12-2003', 'DD-MM-YYYY'), 'Hoàng Tr?ng', 'Trung', 3.7);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(211213588, 'CNTT2', 'CNTT', 1, 2020, TO_DATE('21-01-2003', 'DD-MM-YYYY'), 'Tr?n Tr?ng', 'Duy', 3.1);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(211234124, 'CNTT2', 'CNTT', 0, 2020, TO_DATE('11-11-2003', 'DD-MM-YYYY'), 'Nguy?n Th? Ánh', 'Tuy?t', 3.2);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(211657450, 'CNTT2', 'CNTT', 0, 2020, TO_DATE('09-12-2003', 'DD-MM-YYYY'), 'Tr?n Kim', 'Anh', 3.3);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(211547903, 'CNTT2', 'CNTT', 0, 2020, TO_DATE('10-09-2003', 'DD-MM-YYYY'), 'Tr?n Th?', 'Dung', 3.4);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(211987098, 'CNTT2', 'CNTT', 0, 2020, TO_DATE('19-09-2003', 'DD-MM-YYYY'), 'Tr?n V? Th?', 'Lan', 3.0);

INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(211123577, 'CNTT3', 'CNTT', 1, 2021, TO_DATE('19-01-2004', 'DD-MM-YYYY'), 'Nguy?n V?n', 'V?', 2.8);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(211223588, 'CNTT3', 'CNTT', 1, 2021, TO_DATE('13-12-2004', 'DD-MM-YYYY'), 'Hoàng Tr?ng', 'Nguyên', 3.7);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(211213598, 'CNTT3', 'CNTT', 1, 2021, TO_DATE('21-01-2004', 'DD-MM-YYYY'), 'Tr?n Tr?ng', 'Hùng', 3.1);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(211234144, 'CNTT3', 'CNTT', 0, 2021, TO_DATE('11-11-2004', 'DD-MM-YYYY'), 'Nguy?n Th? Ánh', 'D??ng', 3.2);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(211657455, 'CNTT3', 'CNTT', 0, 2021, TO_DATE('09-12-2004', 'DD-MM-YYYY'), 'Tr?n Kim', 'Tuy?n', 3.3);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(211547933, 'CNTT3', 'CNTT', 0, 2021, TO_DATE('10-09-2004', 'DD-MM-YYYY'), 'Tr?n Th?', 'H?ng', 3.4);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(211987088, 'CNTT3', 'CNTT', 0, 2021, TO_DATE('19-09-2004', 'DD-MM-YYYY'), 'Tr?n V? Th?', 'Liên', 3.0);

INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(231123571, 'CNTT5', 'CNTT', 1, 2022, TO_DATE('19-01-2005', 'DD-MM-YYYY'), 'Nguy?n V?n', 'V?', 2.8);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(231223581, 'CNTT5', 'CNTT', 1, 2022, TO_DATE('13-12-2005', 'DD-MM-YYYY'), 'Hoàng Tr?ng', 'Nguyên', 3.7);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(231213591, 'CNTT5', 'CNTT', 1, 2022, TO_DATE('21-01-2005', 'DD-MM-YYYY'), 'Tr?n Tr?ng', 'Hùng', 3.1);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(231234144, 'CNTT5', 'CNTT', 0, 2022, TO_DATE('11-11-2005', 'DD-MM-YYYY'), 'Nguy?n Th? Ánh', 'D??ng', 3.2);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(231657455, 'CNTT5', 'CNTT', 0, 2022, TO_DATE('09-12-2005', 'DD-MM-YYYY'), 'Tr?n Kim', 'Tuy?n', 3.3);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(231547933, 'CNTT5', 'CNTT', 0, 2022, TO_DATE('10-09-2005', 'DD-MM-YYYY'), 'Tr?n Th?', 'H?ng', 3.4);
INSERT INTO tblSinhVien (MSV, maLop, maChuongTrinhDaoTao, gioiTinh, namNhapHoc, ngaySinh, hoDem, ten, GPA)
VALUES 
(231987088, 'CNTT5', 'CNTT', 0, 2022, TO_DATE('19-09-2005', 'DD-MM-YYYY'), 'Tr?n V? Th?', 'Liên', 3.0);

--tblSinhVienTGLopHocPhan
INSERT INTO tblSinhVienTGLop (maLopHocPhan, MSV, diemQuaTrinh, diemThi)
VALUES (1, 211123456, 8, 7);

INSERT INTO tblSinhVienTGLop (maLopHocPhan, MSV, diemQuaTrinh, diemThi)
VALUES (2, 211123456, 9, 7.5);

INSERT INTO tblSinhVienTGLop (maLopHocPhan, MSV, diemQuaTrinh, diemThi)  
VALUES (3, 211223452, 9, 8);

INSERT INTO tblSinhVienTGLop (maLopHocPhan, MSV, diemQuaTrinh, diemThi)
VALUES (5, 211213123, 7.5, 6); 

INSERT INTO tblSinhVienTGLop (maLopHocPhan, MSV, diemQuaTrinh, diemThi)
VALUES (7, 211223452, 8, 7);

INSERT INTO tblSinhVienTGLop (maLopHocPhan, MSV, diemQuaTrinh, diemThi)  
VALUES (10, 211234456, 8, 9);

INSERT INTO tblSinhVienTGLop (maLopHocPhan, MSV, diemQuaTrinh, diemThi)
VALUES (12, 211987646, 9, 8); 

INSERT INTO tblSinhVienTGLop (maLopHocPhan, MSV, diemQuaTrinh, diemThi) 
VALUES (13, 211657587, 9, 6.5);

INSERT INTO tblSinhVienTGLop (maLopHocPhan, MSV, diemQuaTrinh, diemThi)
VALUES (14, 211987453, 6, 5.5);
--
INSERT INTO tblSinhVienTGLop (maLopHocPhan, MSV, diemQuaTrinh, diemThi)
VALUES (3, 211223452, 9, 8);

INSERT INTO tblSinhVienTGLop (maLopHocPhan, MSV, diemQuaTrinh, diemThi)
VALUES (5, 211223452, 8.5, 7);

INSERT INTO tblSinhVienTGLop (maLopHocPhan, MSV, diemQuaTrinh, diemThi) 
VALUES (7, 211223452, 8, 7); 

INSERT INTO tblSinhVienTGLop (maLopHocPhan, MSV, diemQuaTrinh, diemThi)
VALUES (11, 211223452, 7.5, 8);

INSERT INTO tblSinhVienTGLop (maLopHocPhan, MSV, diemQuaTrinh, diemThi)  
VALUES (14, 211223452, 9, 8.5);

--
INSERT INTO tblSinhVienTGLop (maLopHocPhan, MSV, diemQuaTrinh, diemThi)
VALUES (1, 211213123, 8.5, 7);

INSERT INTO tblSinhVienTGLop (maLopHocPhan, MSV, diemQuaTrinh, diemThi)
VALUES (2, 211213123, 9, 8); 

INSERT INTO tblSinhVienTGLop (maLopHocPhan, MSV, diemQuaTrinh, diemThi)
VALUES (3, 211213123, 8, 7.5);

INSERT INTO tblSinhVienTGLop (maLopHocPhan, MSV, diemQuaTrinh, diemThi) 
VALUES (4, 211213123, 7, 6);

INSERT INTO tblSinhVienTGLop (maLopHocPhan, MSV, diemQuaTrinh, diemThi)
VALUES (5, 211213123, 7.5, 6);
--tblDiem
-- D? li?u m?u cho b?ng tblDiem
-- D? li?u m?u cho b?ng tblDiem
INSERT INTO tblDiem (MSV, kyHoc, diemGPA, diemRenLuyen)
VALUES 
(211123456, 1, 3.5, 85);
INSERT INTO tblDiem (MSV, kyHoc, diemGPA, diemRenLuyen)
VALUES 
(211223452, 1, 3.7, 90);
INSERT INTO tblDiem (MSV, kyHoc, diemGPA, diemRenLuyen)
VALUES 
(211213123, 1, 3.1, 78);
INSERT INTO tblDiem (MSV, kyHoc, diemGPA, diemRenLuyen)
VALUES 
(211234456, 1, 3.2, 88);
INSERT INTO tblDiem (MSV, kyHoc, diemGPA, diemRenLuyen)
VALUES 
(211657587, 1, 3.4, 92);
INSERT INTO tblDiem (MSV, kyHoc, diemGPA, diemRenLuyen)
VALUES 
(211987646, 1, 3.8, 95);
INSERT INTO tblDiem (MSV, kyHoc, diemGPA, diemRenLuyen)
VALUES 
(211987453, 1, 2.9, 75);

-- D? li?u m?u cho k? h?c th? 2
INSERT INTO tblDiem (MSV, kyHoc, diemGPA, diemRenLuyen)
VALUES 
(211123456, 2, 3.6, 88);
INSERT INTO tblDiem (MSV, kyHoc, diemGPA, diemRenLuyen)
VALUES 
(211223452, 2, 3.9, 92);
INSERT INTO tblDiem (MSV, kyHoc, diemGPA, diemRenLuyen)
VALUES 
(211213123, 2, 3.2, 80);
INSERT INTO tblDiem (MSV, kyHoc, diemGPA, diemRenLuyen)
VALUES 
(211234456, 2, 3.5, 90);
INSERT INTO tblDiem (MSV, kyHoc, diemGPA, diemRenLuyen)
VALUES 
(211657587, 2, 3.6, 94);
INSERT INTO tblDiem (MSV, kyHoc, diemGPA, diemRenLuyen)
VALUES 
(211987646, 2, 4.0, 97);
INSERT INTO tblDiem (MSV, kyHoc, diemGPA, diemRenLuyen)
VALUES 
(211987453, 2, 3.0, 70);

select * from tblDiem;

--Truy van
--Truy van co ban
SELECT * FROM tblSinhVien;
SELECT tenMonHoc, soTinChi FROM tblMonHoc;
SELECT * FROM tblLopHocPhan WHERE namHoc = 2023;

SELECT maLop, COUNT(*) AS SoLuongSinhVien
FROM tblSinhVien
GROUP BY maLop;

SELECT maLop, AVG(GPA) AS DiemTrungBinh
FROM tblSinhVien
GROUP BY maLop;

--truy van long nhau 
SELECT hoDem || ' ' || ten AS "H? và Tên", GPA
FROM tblSinhVien
WHERE maLop = (SELECT maLop FROM tblLop WHERE tenLop = 'CNTT1-K62');

SELECT SV.ten AS "Ten Sinh Vien", SVTL.diemThi
FROM tblSinhVienTGLop SVTL
JOIN tblSinhVien SV ON SVTL.MSV = SV.MSV
WHERE SVTL.maLopHocPhan IN (SELECT maLopHocPhan FROM tblLopHocPhan WHERE maMonHoc = (SELECT maMonHoc FROM tblMonHoc WHERE tenMonHoc = 'Toán cao c?p'));

SELECT ten, GPA
FROM tblSinhVien
WHERE maLop = (SELECT maLop FROM tblLop WHERE tenLop = 'CNTT1-K62') 
ORDER BY GPA DESC;

SELECT tenLopHocPhan, hoDem || ' ' || ten AS "Ho Ten Giang vien"
FROM tblLopHocPhan
INNER JOIN tblNhanVien ON tblLopHocPhan.maNhanVien = tblNhanVien.maNhanVien;

SELECT SV.ten, SV.GPA, LHP.tenLopHocPhan 
FROM tblSinhVien SV 
JOIN tblSinhVienTGLop SVTL ON SV.MSV = SVTL.MSV 
JOIN tblLopHocPhan LHP ON SVTL.maLopHocPhan = LHP.maLopHocPhan 
WHERE LHP.maNhanVien IN (SELECT maNhanVien FROM tblNhanVien WHERE ten = 'Anh');


select sv.MSV, sv.hodem as "H? ??m", sv.ten as "Tên", lhp.tenLopHocPhan as "Tên l?p h?c ph?n", mon.maMonHoc as "Mã môn h?c", mon.tenMonHoc as "Tên môn h?c"
from tblSinhVien sv
join tblSinhVienTGLop svtl on sv.msv = svtl.msv
join tblLopHocPhan lhp on svtl.maLopHocPhan = lhp.maLopHocPhan
join tblMonHoc mon on lhp.maMonHoc = mon.maMonHoc;

SELECT 
    sv.MSV, 
    sv.hoDem || ' ' || sv.ten AS HoTen,
    COUNT(svtl.maLopHocPhan) AS SoMonDaHoc
FROM 
    tblSinhVien sv
        LEFT JOIN tblSinhVienTGLop svtl 
            ON sv.MSV = svtl.MSV
GROUP BY 
    sv.MSV, 
    sv.hoDem || ' ' || sv.ten;

select sv.hodem, sv.ten
from tblSinhVien sv 
join tblChuongTringDaoTao ct on sv.maChuongTrinhDaoTao = ct.maChuongTrinhDaoTao;

--truy van nhom
SELECT maLop, AVG(GPA) AS avgGPA
FROM tblSinhVien
GROUP BY maLop;

SELECT maKhoa, COUNT(*) AS soSinhVien
FROM tblLop
GROUP BY maKhoa;

SELECT maChuongTrinhDaoTao, SUM(soTinChi) AS tongTinChi
FROM tblMonHoc
GROUP BY maChuongTrinhDaoTao;

SELECT maLopHocPhan, AVG(COALESCE(diemThi, 0)) AS "?i?m thi trung bình"
FROM tblSinhVienTGLop
GROUP BY maLopHocPhan;

SELECT maLopHocPhan, COUNT(MSV) AS soLuongSinhVien
FROM tblSinhVienTGLop
GROUP BY maLopHocPhan;

-- Cac ham thong ke
SELECT maLopHocPhan, COUNT(MSV) AS soLuongSinhVien
FROM tblSinhVienTGLop
GROUP BY maLopHocPhan;

SELECT maChuongTrinhDaoTao, SUM(soTinChi) AS tongTinChi
FROM tblMonHoc
GROUP BY maChuongTrinhDaoTao;

SELECT maLopHocPhan, AVG(COALESCE(diemThi, 0)) AS avgDiemThi
FROM tblSinhVienTGLop
GROUP BY maLopHocPhan;

SELECT maLopHocPhan,  MAX(COALESCE(diemThi, 0)) AS maxDiemThi
FROM tblSinhVienTGLop
GROUP BY maLopHocPhan;

SELECT maLopHocPhan, MIN(COALESCE(diemThi, 0)) AS minDiemThi
FROM tblSinhVienTGLop
GROUP BY maLopHocPhan;

--pl/sql
--1. Tinh GPA cua moi sinh vien dua vao bang Diem va cap nhat lai vao bang tblsinhVien
CREATE OR REPLACE PROCEDURE tinhGPADiem(p_msv NUMBER) AS
  v_diemGPA NUMBER;
BEGIN
  SELECT AVG(COALESCE(diemGPA, 0))
  INTO v_diemGPA
  FROM tblDiem
  WHERE MSV = p_msv
  GROUP BY MSV;

  -- Update ?i?m GPA trung bình c?a sinh viên trong b?ng tblSinhVien
  UPDATE tblSinhVien
  SET GPA = v_diemGPA
  WHERE MSV = p_msv;

  COMMIT;
END tinhGPADiem;
/

BEGIN
  tinhGPADiem(211213123); -- Thay 123 b?ng mã s? sinh viên c?n tính GPA
END;
/

select * from tblSinhVien where tblSinhVien.MSV = 211213123;

--Dem so luong sinh vien 1 khoa
CREATE OR REPLACE FUNCTION demSoLuongSinhVienTheoKhoa(maKhoa VARCHAR2) RETURN NUMBER IS
  soLuong NUMBER := 0;
BEGIN
  FOR rec IN (SELECT COUNT(*) AS countSV FROM tblLop WHERE maKhoa = maKhoa) LOOP
    soLuong := rec.countSV;
  END LOOP;
  
  RETURN soLuong;
END;
/

SELECT demSoLuongSinhVienTheoKhoa('CNTT') FROM dual;

CREATE OR REPLACE PROCEDURE get_monhoc_by_msv (
    p_msv IN NUMBER 
)
AS 
    v_ten NVARCHAR2(100);
    v_mamh NUMBER;
BEGIN
    FOR sv IN (
        SELECT s.MSV, mh.tenMonHoc, mh.maMonHoc
        FROM tblSinhVien s JOIN tblChuongTrinhDaoTao ct ON s.maChuongTrinhDaoTao = ct.maChuongTrinhDaoTao
                           JOIN tblMonHoc mh ON ct.maChuongTrinhDaoTao = mh.maChuongTrinhDaoTao
        WHERE s.MSV = p_msv
    ) LOOP
        v_ten := sv.tenMonHoc;
        v_mamh := sv.maMonHoc;
        
        DBMS_OUTPUT.PUT_LINE('MSV: ' || p_msv || ' - Môn h?c: ' || v_ten || ' - Mã môn: ' || v_mamh);    
    END LOOP;
END;
/
-- Capo nhat lai ten lop
CREATE OR REPLACE PROCEDURE capNhatTenLop(maLop VARCHAR2, tenLopMoi NVARCHAR2) IS
BEGIN
  UPDATE tblLop
  SET tenLop = tenLopMoi
  WHERE maLop = maLop;
  COMMIT;
END;
/

BEGIN
  capNhatTenLop("CNTT5","CNTT6-K62"); 
END;
/

--Lay danh sach sinh vien theo khoa
CREATE OR REPLACE FUNCTION layDanhSachSinhVienTheoLop(maLop VARCHAR2) RETURN SYS_REFCURSOR IS
  cur SYS_REFCURSOR;
BEGIN
  OPEN cur FOR
    SELECT MSV, ten, maLop
    FROM tblSinhVien S
    JOIN tblLop L ON S.maLop = L.maLop;
  RETURN cur;
END;
/

select * from table (layDanhSachSinhVienTheoLop('CNTT1'));

create or replace function laySinhVienLop (p_malop in varchar2) 
RETURN SYS_REFCURSOR
is
    cur SYS_REFCURSOR;
begin
    OPEN cur FOR
        select 
            sv.MSV, sv.hoDem, sv.ten, sv.namNhapHoc
        from
            tblSinhVien sv
        where
            sv.maLop = p_malop
        ORDER BY sv.hoDem, sv.ten;

    RETURN cur;
END;
/

var svien REFCURSOR;
exec :svien := laySinhVienLop('CNTT1');
print svien;

select * from  (LAYSINHVIENLOP('CNTT1'));

CREATE OR REPLACE TRIGGER trg_sinhvien_email
BEFORE INSERT OR UPDATE ON tblSinhVien
FOR EACH ROW
BEGIN
  :NEW.email := :NEW.ten || :NEW.MSV || '@lms.utc.edu.vn';
END;

UPDATE tblSinhVien 
SET email = ten || MSV || '@lms.utc.edu.vn';

VAR f REFCURSOR
EXEC :f := laysinhvientulop('CNTT1');

PRINT f;
--instance
CREATE USER SinhVien IDENTIFIED BY 123456;
GRANT SELECT ON tblSinhVien TO SinhVien;
GRANT UPDATE ON tblSinhVien TO SinhVien WITH GRANT OPTION
GRANT SELECT ON tblDiem TO SinhVien;
GRANT SELECT ON tblLop TO SinhVien;
GRANT SELECT ON tblSinhVienTGLop TO SinhVien;
GRANT SELECT ON tblBoMon TO SinhVien;
GRANT SELECT ON tblLopHocPhan TO SinhVien;
GRANT SELECT ON tblKhoa TO SinhVien;
GRANT SELECT ON tblLop TO SinhVien;

CREATE USER GiaoVien IDENTIFIED BY 123456;
GRANT INSERT ON tblDiem TO GiaoVien;
GRANT INSERT ON tblSinhVienTGLop TO GiaoVien;

CREATE USER QuanLy IDENTIFIED BY 123456;
GRANT ALL PRIVILEGES ON tblSinhVien TO QuanLy;
GRANT ALL PRIVILEGES ON tblDiem TO QuanLy;
GRANT ALL PRIVILEGES ON tblLop TO QuanLy;
GRANT GRANT ANY OBJECT PRIVILEGE TO QuanLy;
