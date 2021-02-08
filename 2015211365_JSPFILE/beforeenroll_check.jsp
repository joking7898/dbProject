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

		 CallableStatement cstmt = myConn.prepareCall("{call beforeperson(?, ?, ?)}");
		 cstmt.setString(1, c_id);
		 cstmt.registerOutParameter(2, java.sql.Types.VARCHAR);
		 cstmt.registerOutParameter(3, java.sql.Types.VARCHAR);

		 try {
			cstmt.execute();
			result = "모집인원은"+cstmt.getString(3)+"명이며, 현재 수강신청을 장바구니 신청을 한 학생은 총 "+ cstmt.getString(2)+"명입니다.";
			System.out.println(result);
	%>
	<script>	
	alert("<%=result%>");
		location.href = "beforeenroll.jsp";
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