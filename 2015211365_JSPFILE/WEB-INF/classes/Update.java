
package updateBean;

public class Update {
	private String s_name;
	private String s_addr;
	private int s_pwd;
	private String s_college;
	private String s_major;

	public Update() {
		s_name = null;
		s_addr = null;
		s_pwd = 0;
		s_college = null;
		s_major = null;
	}
	public void setsName(String s_name) {
		this.s_name = s_name;
	}

	public void setsAddr(String s_addr) {
		this.s_addr = s_addr;
	}

	public void setsPwd(int s_pwd) {
		this.s_pwd = s_pwd;
	}

	public void setsCollege(String s_college) {
		this.s_college = s_college;
	}

	public void setsMajor(String s_major){
		this.s_major = s_major;
	}

	public String getsName() {
		return s_name;
	}

	public String getsAddr() {
		return s_addr;
	}

	public int getsPwd() {
		return s_pwd;
	}

	public String getsCollege() {
		return s_college;
	}

	public String getsMajor(){
		return s_major;
	}


}
