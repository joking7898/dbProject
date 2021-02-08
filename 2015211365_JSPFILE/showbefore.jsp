<%@ page language="java" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>
<%@ page import="java.sql.*"%>
<!DOCTYPE html>

<html><head><title>수강신청 입력</title></head>
<body>

	<%@ include file="top.jsp"%>
	<% if (session_id == null)	response.sendRedirect("login.jsp");	%>
	
	<table width="75%" align="center" border>	<br>
		<caption><%=session_name%>님 의 모의수강 목록입니다.</caption>
		<tr>
			<th>과목번호</th>
			<th>분반</th>
			<th>과목명</th>
			<th>학점</th>
			<th>수강신청</th>
		</tr>
		<%
			Connection myConn = null;
			ResultSet myResultSet = null;
			String mySQL = "";
			String dburl = "jdbc:oracle:thin:@210.94.199.20:1521:dblab";
			String user = "ST2015211365"; 
			String passwd = "ST2015211365"; 
			String dbdriver = "oracle.jdbc.driver.OracleDriver";

			try {
				Class.forName(dbdriver);
				myConn = DriverManager.getConnection(dburl, user, passwd);
			} catch (SQLException ex) {
				System.err.println("SQLException: " + ex.getMessage());
			}
		                          
			mySQL = "select e.c_id cid,e.c_id_no cid_no,c.c_name cname,c.c_unit cunit from beforeenroll e, course c "+
			"where e.s_id=" + session_id + "and e.e_year=2020 and e.e_semester=1 and e.c_id=c.c_id and e.c_id_no=c.c_id_no";

			Statement stmt = myConn.createStatement();

			myResultSet = stmt.executeQuery(mySQL);
			if (myResultSet != null) {
				while (myResultSet.next()) {
					String c_id = myResultSet.getString("cid");
					int c_id_no = myResultSet.getInt("cid_no");
					String c_name = myResultSet.getString("cname");
					int c_unit = myResultSet.getInt("cunit");
		%>
		<tr>
			<td align="center"><%=c_id%></td>
			<td align="center"><%=c_id_no%></td>
			<td align="center"><%=c_name%></a></td>
			<td align="center"><%=c_unit%></td>
			<td align="center"><a href="showbefore_verify.jsp?c_id=<%=c_id%>&c_id_no=<%=c_id_no%>">모의 수강 취소</a></td>
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