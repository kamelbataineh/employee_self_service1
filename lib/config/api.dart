
const String url                   = "http://10.0.2.2:5000/api/";
const String Weburl                = "http://localhost:5000/api/";
const String Weburl1               = "http://localhost:5000/api";

const String adminregister         = Weburl + 'admin/register';
const String adminlogin            = Weburl + 'admin/login';
//
///
//
const String admindashboard        = Weburl + 'departments/create';
const String admindashboardAll     = Weburl + "departments/all";
//
///
//
const String employeeAdd           = Weburl + 'employee/create';
const String addEmployeeApi        = Weburl + "employee/create";
const String getEmployeesCount     = Weburl + "employee/employees/count/all";
//
///
//

String employeeByDepartment(String departmentId) {
  return Weburl + 'employee/employees/department/$departmentId';
}

String getEmployeeById(String id) {
  return  Weburl + 'employee/employees/$id';
}

