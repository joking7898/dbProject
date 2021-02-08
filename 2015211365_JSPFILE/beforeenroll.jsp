<%@ page language="java" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>
<%@ page import="java.sql.*"%>
<!DOCTYPE html>

<html><head><title>모의 수강신청</title></head>
<body>

	<%@ include file="top.jsp"%>
	<% if (session_id == null)	response.sendRedirect("login.jsp");	%>
	
	<table width="75%" align="center" border>	<br>
		<tr>
			<th>과목번호</th>
			<th>분반</th>
			<th>과목명</th>
			<th>학점</th>
			<th>모의수강</th>
			<th>수강후기</th>
		</tr>
		<%
			Connection myConn = null;
			ResultSet myResultSet = null;
			String mySQL = "";
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
		                          
								  
			mySQL = "select * from course where c_id not in" 
					+ "(select c_id from beforeenroll where s_id = '" + session_id
					+ "' and e_year = '2020' and e_semester = '1')" + "and c_id in"
					+ "(select c_id from teach where t_year = '2020' and t_semester = '1' )";

			Statement stmt = myConn.createStatement();

			myResultSet = stmt.executeQuery(mySQL);

			if (myResultSet != null) {
				while (myResultSet.next()) {
					String c_id = myResultSet.getString("c_id");
					int c_id_no = myResultSet.getInt("c_id_no");
					String c_name = myResultSet.getString("c_name");
					int c_unit = myResultSet.getInt("c_unit");
		%>
		<tr>
			<td align="center"><%=c_id%></td>
			<td align="center"><%=c_id_no%></td>
			<td align="center"><a href="beforeenroll_check.jsp?c_id=<%=c_id%>"><%=c_name%></a></td>
			<td align="center"><%=c_unit%></td>
			<td align="center"><a href="beforeenroll_verify.jsp?c_id=<%=c_id%>&c_id_no=<%=c_id_no%>">장바구니 신청</a></td>
			<td align="center">	<button onclick="window.open('studyinfo.jsp?c_id=<%=c_id%>&c_name=<%=c_name%>','강의평가 내용','width=900,height=600,location=no,status=no,scrollbars=yes');">강의평가보기</button></td>
		</tr>
		<%
			  }
			}
			stmt.close();
			myConn.close();
		%>
	</table>
</body>
</html>