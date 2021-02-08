package updateBean;

import java.sql.*;
import java.util.*;
import javax.sql.*;
import oracle.jdbc.driver.*;
import oracle.jdbc.pool.*;
import updateBean.*;

public class UpdateMgr {

	private OracleConnectionPoolDataSource ocpds = null;
	private PooledConnection pool = null;

	public UpdateMgr() {
		try {

			ocpds = new OracleConnectionPoolDataSource();
			ocpds.setURL("jdbc:oracle:thin:@210.94.199.20:1521:dblab");
			ocpds.setUser("ST2015211365");
			ocpds.setPassword("ST2015211365");

			pool = ocpds.getPooledConnection();
		} catch (Exception e) {
			System.out.println("Error : Connection Failed");
		}
	}

	public Vector GetStdInfo(String s_id){
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		Vector vecList = new Vector();

		try {
			conn = pool.getConnection();
			
			String mySQL = "select s.s_name name, s.s_addr addr, s.s_pwd pwd, s.s_college college, s.s_major major from student s where s_id=?" ;
			pstmt = conn.prepareStatement(mySQL);
			pstmt.setString(1, s_id);
			rs = pstmt.executeQuery();

			while(rs.next()){
				Update updates = new Update();
				updates.setsName(rs.getString("name"));
				updates.setsAddr(rs.getString("addr"));
				updates.setsPwd(rs.getInt("pwd"));
				updates.setsCollege(rs.getString("college"));
				updates.setsMajor(rs.getString("major"));
				vecList.add(updates);
			}
			pstmt.close();
			conn.close();
		}	catch(Exception ex) {
			System.out.println("Exception" + ex);
		}

		return vecList;
	}

	public void Updateinfo(String s_id, String s_name, String s_addr, int s_pwd, String s_college, String s_major){
		Connection conn = null;
		PreparedStatement pstmt = null;
		try{
			conn = pool.getConnection();

			String mySQL  = "update student set s_addr =?, s_name =?, s_college =?, s_major =?, s_pwd =? where s_id =? ";
			pstmt = conn.prepareStatement(mySQL);
			pstmt.setString(1, s_addr);
			pstmt.setString(2, s_name);
			pstmt.setString(3, s_college);
			pstmt.setString(4, s_major);
			pstmt.setInt(5, s_pwd);
			pstmt.setString(6, s_id);

			pstmt.executeQuery();
			pstmt.close();
			conn.close();
		}
		catch (Exception ex) {
			System.out.println("Exception" + ex);
		};
	}
}