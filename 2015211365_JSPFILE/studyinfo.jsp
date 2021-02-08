<%@ page language="java" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>
<%@ page import="java.sql.*"%>
<!DOCTYPE html>

<html><head><title>모의 수강신청</title></head>
<body>
	<%
     String cname = request.getParameter("c_name");
    %>
	<table width="75%" align="center" border>	<br>
    <caption><%= cname %>의 수강후기내용</caption>
		<tr>
            <th>No.</th>
			<th>수강후기내용</th>
		</tr>
		<%
            String cid = request.getParameter("c_id");

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
		                          			  
			mySQL = "select NUM,info from studyinfo where c_id = '"+ cid +"'";

			Statement stmt1 = myConn.createStatement();

			myResultSet = stmt1.executeQuery(mySQL);

			if (myResultSet != null) {
				while (myResultSet.next()) {
                    int num1 = myResultSet.getInt("NUM");
					String info = myResultSet.getString("info");
		%>
        <tr>
            <td align="center"><%=num1%></td>
			<td align="center"><%=info%></td>
		</tr>
		<%
			  }
			}
			stmt1.close();
			myConn.close();
		%>
	</table>
</body>
</html>