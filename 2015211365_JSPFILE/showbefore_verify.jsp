<%@ page language="java" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>
	<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head><title>수강신청 입력</title></head>
<body>

	<%
		String s_id = (String) session.getAttribute("user");
		String c_id = request.getParameter("c_id");
		int c_id_no = Integer.parseInt(request.getParameter("c_id_no"));

		Connection myConn = null;
		String result = null;
		String dburl = "jdbc:oracle:thin:@210.94.199.20:1521:dblab";
		String user = "ST2015211365"; // 본인 아이디(ex.STxxxxxxxxxx)
		String passwd = "ST2015211365"; // 본인 패스워드(ex.STxxxxxxxxxx)
		String dbdriver = "oracle.jdbc.driver.OracleDriver";

		try {
			Class.forName(dbdriver);
			myConn = DriverManager.getConnection(dburl, user, passwd);
		} catch (SQLException ex) {
			System.err.println("SQLException: " + ex.getMessage());
		}

		CallableStatement cstmt = myConn.prepareCall("{call DeleteBefore(?, ?, ?)}");
		cstmt.setString(1, s_id);
		cstmt.setString(2, c_id);
		cstmt.setInt(3, c_id_no);
		try {
			cstmt.execute();
	%>
	<script>
		alert("삭제되었습니다.");
		location.href = "showbefore.jsp";
	</script>
	<%
		} catch (SQLException ex) {
			System.err.println("SQLException: " + ex.getMessage());
		} finally {
			if (cstmt != null)
				try {
					myConn.commit();
					cstmt.close();
					myConn.close();
				} catch (SQLException ex) {

				}
		}
	%>
</body></html>

