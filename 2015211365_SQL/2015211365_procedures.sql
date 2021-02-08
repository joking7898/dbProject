/* 모의 수강 신청 관련 프로시져 */
CREATE OR REPLACE PROCEDURE BeforeIntEnroll(
   sStudentId IN VARCHAR2,
   sCourseId IN VARCHAR2,
   nCourseIdNo IN NUMBER,
   result OUT VARCHAR2
   )
IS
   beenrollerror1 EXCEPTION;
   beenrollerror2 EXCEPTION;
   duplicate_time EXCEPTION;
   nYear NUMBER;
   nSemester NUMBER;
   nSumCourseUnit NUMBER;
   nCourseUnit NUMBER;
   nCnt NUMBER;
   
CURSOR checktime IS
SELECT COUNT(*)
INTO nCnt
FROM (SELECT t_time
FROM teach
WHERE t_year = nYear and t_semester = nSemester
and c_id = sCourseId and c_id_no = nCourseIdNo
INTERSECT
SELECT t.t_time
FROM teach t, beforeenroll e
WHERE e.s_id = sStudentId and e.e_year = nYear
and e.e_semester = nSemester and t.t_year = nYear
and t.t_semester = nSemester and e.c_id = t.c_id
and e.c_id_no = t.c_id_no);
count1 NUMBER;

BEGIN
   result := ' ';
   DBMS_OUTPUT.put_line('#');
   DBMS_OUTPUT.put_line(sStudentId || '님이 과목번호 ' || sCourseId ||
   ', 분반 ' || TO_CHAR(nCourseIdNo) || '의 수강 등록을 요청하였습니다.');

   /* 년도, 학기 알아내기 */
   nYear := Date2EnrollYear(SYSDATE);
   nSemester := Date2EnrollSemester(SYSDATE);

   /* 모의수강 18학점 이상으로 신청했을때 에러 발생. */
   SELECT SUM(c.c_unit)
   INTO nSumCourseUnit
   FROM course c, beforeenroll e
   WHERE e.s_id = sStudentId and e.e_year = nYear and e.e_semester = nSemester
   and e.c_id = c.c_id and e.c_id_no = c.c_id_no;

   SELECT c_unit
   INTO nCourseUnit
   FROM course
   WHERE c_id = sCourseId and c_id_no = nCourseIdNo;

   IF(nSumCourseUnit + nCourseUnit > 18) THEN -- 사용자 정의 예외
      RAISE beenrollerror1;
   END IF;

   /* 동일한 과목 신청했을때 에러 발생*/
   SELECT COUNT(*)
   INTO nCnt
   FROM beforeenroll
   WHERE s_id = sStudentId and c_id = sCourseId;

   IF(nCnt > 0) THEN
      RAISE beenrollerror2;
   END IF;

   /* 신청과목이 이전 신청과목과 중복될경우 에러*/
	open checktime;
	FETCH checktime INTO count1;

	DBMS_OUTPUT.PUT_LINE('중복되는 시간: ' || count1);

	CLOSE checktime;
   IF (nCnt >0) THEN
      RAISE duplicate_time;
   END IF;

   /*수강신청 등록 */
   INSERT INTO beforeenroll(beennum,S_ID, C_ID, C_ID_NO, E_YEAR, E_SEMESTER)
   VALUES (null,sStudentId, sCourseId, nCourseIdNo, nYear, nSemester);
   COMMIT;
   
   result := '수강신청 등록이 완료되었습니다.';

   EXCEPTION
   WHEN beenrollerror1 THEN
   result := '최대 모의수강신청 학점을 초과하였습니다';
   WHEN beenrollerror2 THEN
   result := '모의신청한 과목을 선택하였습니다';
   WHEN duplicate_time THEN
   result := '이미 등록된 모의신청 중 중복되는 시간이 존재합니다';
   WHEN OTHERS THEN
   ROLLBACK;
   result := SQLCODE;
   END;
   
 /* 수강신청 부분 프로시저*/

CREATE OR REPLACE PROCEDURE InsertEnroll(sStudentId IN VARCHAR2,
   sCourseId IN VARCHAR2,
   nCourseIdNo IN NUMBER,
   result OUT VARCHAR2)
IS
   too_many_sumCourseUnit EXCEPTION;
   too_many_courses EXCEPTION;
   too_many_students EXCEPTION;
   duplicate_time EXCEPTION;
   nYear NUMBER;
   nSemester NUMBER;
   nSumCourseUnit NUMBER;
   nCourseUnit NUMBER;
   nCnt NUMBER;
   nTeachMax NUMBER;
CURSOR test1 IS
SELECT COUNT(*)
INTO nCnt
FROM (SELECT t_time
FROM teach
WHERE t_year = nYear and t_semester = nSemester
and c_id = sCourseId and c_id_no = nCourseIdNo
INTERSECT
SELECT t.t_time
FROM teach t, enroll e
WHERE e.s_id = sStudentId and e.e_year = nYear
and e.e_semester = nSemester and t.t_year = nYear
and t.t_semester = nSemester and e.c_id = t.c_id
and e.c_id_no = t.c_id_no);
count1 NUMBER;
BEGIN
   result := ' ';
   DBMS_OUTPUT.put_line('#');
   DBMS_OUTPUT.put_line(sStudentId || '님이 과목번호 ' || sCourseId ||
   ', 분반 ' || TO_CHAR(nCourseIdNo) || '의 수강 등록을 요청하였습니다.');

   /* 년도, 학기 알아내기 */
   nYear := Date2EnrollYear(SYSDATE);
   nSemester := Date2EnrollSemester(SYSDATE);

   /* 에러 처리 1 : 최대학점 초과여부 */
   SELECT SUM(c.c_unit)
   INTO nSumCourseUnit
   FROM course c, enroll e
   WHERE e.s_id = sStudentId and e.e_year = nYear and e.e_semester = nSemester
   and e.c_id = c.c_id and e.c_id_no = c.c_id_no;

   SELECT c_unit
   INTO nCourseUnit
   FROM course
   WHERE c_id = sCourseId and c_id_no = nCourseIdNo;

   IF(nSumCourseUnit + nCourseUnit > 18) THEN -- 사용자 정의 예외
      RAISE too_many_sumCourseUnit;
   END IF;

   /* 에러 처리 2 : 동일한 과목 신청 여부 */
   SELECT COUNT(*)
   INTO nCnt
   FROM enroll
   WHERE s_id = sStudentId and c_id = sCourseId;

   IF(nCnt > 0) THEN
      RAISE too_many_courses;
   END IF;

   /* 에러 처리 3 : 수강신청 인원 초과 여부 */
   SELECT t_max
   INTO nTeachMax
   FROM teach
   WHERE t_year = nYear and t_semester = nSemester and c_id = sCourseId
   and c_id_no = nCourseIdNo;

   SELECT COUNT(*)
   INTO nCnt
   FROM enroll
   WHERE e_year = nYear and e_semester = nSemester
   and c_id = sCourseId and c_id_no = nCourseIdNo;
   IF (nCnt >= nTeachMax) THEN
      RAISE too_many_students;
   END IF;

   /* 에러 처리 4 : 신청한 과목들 시간 중복 여부 */
open test1;
FETCH test1 INTO count1;

DBMS_OUTPUT.PUT_LINE('중복되는 시간: ' || count1);

CLOSE test1;
   IF (nCnt >0) THEN
      RAISE duplicate_time;
   END IF;

   /*수강신청 등록 */
   INSERT INTO enroll(S_ID, C_ID, C_ID_NO, E_YEAR, E_SEMESTER)
   VALUES (sStudentId, sCourseId, nCourseIdNo, nYear, nSemester);
   COMMIT;
   result := '수강신청 등록이 완료되었습니다.';

   EXCEPTION
   WHEN too_many_sumCourseUnit THEN
   result := '최대학점을 초과하였습니다';
   WHEN too_many_courses THEN
   result := '이미 등록된 과목을 신청하였습니다';
   WHEN too_many_students THEN
   result := '수강신청 인원이 초과되어 등록이 불가능합니다';
   WHEN duplicate_time THEN
   result := '이미 등록된 과목 중 중복되는 시간이 존재합니다';
   WHEN OTHERS THEN
   ROLLBACK;
   result := SQLCODE;
   END; 
   
/*사람 여석 나오게 하는 프로시저*/
   PROCEDURE Person(
sel_id IN course.c_id%type,
extra_1 out number,
extra out number
)
IS
maximum number;
BEGIN

select count(*) into maximum
from enroll
where c_id =sel_id;
dbms_output.put_line('결과1::'|| maximum);

select t_max into extra_1
from teach
where c_id =sel_id and t_year=2020;
extra := extra_1 - maximum;
dbms_output.put_line('결과2::'|| extra);
commit;
END;

/*모의수강 신청한사람 명수 출력 프로시저*/
PROCEDURE beforeperson(
sel_id IN course.c_id%type,
extra_1 out number
)
IS
BEGIN

select count(*) into maximum
from beforeenroll
where c_id =sel_id;
dbms_output.put_line('결과1::'|| maximum);

select t_max into extra_1
from teach
where c_id =sel_id and t_year=2020;
dbms_output.put_line('결과2::'|| extra_1);
commit;
END;

/*삭제하기 전의 프로시저*/
PROCEDURE DeleteBefore(
sid IN beforeenroll.s_id%type,
cid IN beforeenroll.c_id%type,
cidno IN beforeenroll.c_id_no%type
)
IS
maximum number;
BEGIN

delete from beforeenroll where s_id=sid and c_id=cid and c_id_no=cidno;

commit;
END;

/*시간표 관련 프로시저*/
PROCEDURE SelectTimeTable
   (sStudentId IN VARCHAR2,
   nYear IN NUMBER,
   nSemester IN NUMBER)
IS
   sId COURSE.C_ID%TYPE;
   sName COURSE.C_NAME%TYPE;
   nIdNo COURSE.C_ID_NO%TYPE;
   nUnit COURSE.C_UNIT%TYPE;
   nTime TEACH.T_TIME%TYPE;
   sWhere TEACH.T_WHERE%TYPE;
   nTotUnit NUMBER := 0;

   --명시적 커서 사용
CURSOR cur (sStudentId VARCHAR2, nYear NUMBER, nSemester NUMBER) IS
   SELECT e.c_id, c.c_name, e.c_id_no, c.c_unit, t.t_time, t.t_where
   FROM enroll e, course c, teach t
   WHERE e.s_id = sStudentId and e.e_year = nYear
   and e.e_semester = nSemester
   and t.t_year = nYear and t.t_semester = nSemester
   and e.c_id = c.c_id and e.c_id_no = c.c_id_no
   and c.c_id = t.c_id and c.c_id_no = t.c_id_no
   ORDER BY 5;
BEGIN
   OPEN cur(sStudentId, nYear, nSemester); -- 파라미터가 있는 커서 사용
   DBMS_OUTPUT.put_line('#');
   DBMS_OUTPUT.put_line(TO_CHAR(nYear) || '년도 ' || TO_CHAR(nSemester) || '학기의 ' ||
    sStudentId || ' 님의 수강신청 시간표입니다.');
   LOOP
   FETCH cur INTO sId, sName, nIdNo, nUnit, nTime, sWhere;
   EXIT WHEN cur%NOTFOUND;
   DBMS_OUTPUT.put_line('교시: ' || TO_CHAR(nTime) || ', 과목번호: ' || sID ||
    ', 과목명: ' || sName || ', 분반: ' || TO_CHAR(nIdNo) ||
    ', 학점: ' || TO_CHAR(nUnit) || ' , 장소: ' || sWhere);
   nTotUnit := nTotUnit + nUnit;
   END LOOP;
   DBMS_OUTPUT.put_line('총 ' || TO_CHAR(cur%ROWCOUNT) || ' 과목과 총 '
      || TO_CHAR(nTotUnit) || '학점을 신청하였습니다.');
   CLOSE cur;
END;
/* 1씩 증가시키는 시퀀스 작성 */
CREATE SEQUENCE test_sequence
START WITH 1
INCREMENT BY 1;

/*장바구니 부분 트리거 beennum 자동증가 관련*/
CREATE OR REPLACE TRIGGER beenum_trigger
BEFORE INSERT
ON beforeenroll
REFERENCING NEW AS NEW
FOR EACH ROW
BEGIN
SELECT test_sequence.nextval INTO :NEW.beennum FROM dual;
END;
