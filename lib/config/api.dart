//////////////////////////////////////////////////////
// 🔥 BASE URLS
//////////////////////////////////////////////////////

const String url = "http://10.0.2.2:5000/api/";
const String url1 = "http://10.0.2.2:5000/api";
const String Weburl = "http://localhost:5000/api/";
const String Weburl1 = "http://localhost:5000/api";

//////////////////////////////////////////////////////
// 🔥 ADMIN
//////////////////////////////////////////////////////

const String adminregister = Weburl + 'admin/register';
const String adminlogin = Weburl + 'admin/login';
const String adminsetCompanyLocationApi =
    Weburl + 'admin/set-location';
const String admingetCompanyLocation = Weburl + "admin/company-location";

//////////////////////////////////////////////////////
// 🔥 PLACES (FIXED - لازم functions)
//////////////////////////////////////////////////////

String placesSearch(String query) {
  return Weburl + "places/search?query=$query";
}

String placesDetails(String placeId) {
  return Weburl + "places/details?placeId=$placeId";
}
//////////////////////////////////////////////////////
// 🔥 WRONG INLINE REQUESTS (خليتها للتصحيح فقط)
//////////////////////////////////////////////////////


//////////////////////////////////////////////////////
// 🔥 DEPARTMENTS
//////////////////////////////////////////////////////

const String admindashboard = Weburl + 'departments/create';
const String admindashboardAll = Weburl + "departments/all";

const String admindashboardCreate = Weburl + "departments/create";
const String addSubDepartment = Weburl + "departments/add-sub-department/";

const String admindashboardAddSubDepartment =
    "$url1/departments/add-sub-department";

//////////////////////////////////////////////////////
// 🔥 EMPLOYEE
//////////////////////////////////////////////////////

const String employeeAdd = Weburl + 'employee/create';
const String addEmployeeApi = Weburl + "employee/create";
const String getEmployeesCount = Weburl + "employee/employees/count/all";
const String checkAttendanceUrl = "$url1/api/attendance/check";
const String employeelogin = url + "employee/login";
const String employeegetMyProfile = url + "employee/me";
const String employeeRegister = "${Weburl}employee/register";

String employeeByDepartment(String departmentId) {
  return Weburl + 'employee/employees/department/$departmentId';
}

String getEmployeeById(String id) {
  return Weburl + 'employee/$id';
}

String getEmployeesBySubDepartment(String deptId, String subId) {
  return "$Weburl1/employee/employees/$deptId/$subId";
}

String addEmployeeToSubDepartment = "$Weburl1/employee/add-to-sub";

String getDepartmentById(String id) {
  return "$Weburl1/departments/$id";
}

//////////////////////////////////////////////////////
// 🔥 ATTENDANCE
//////////////////////////////////////////////////////

const String checkInUrl = "$url1/attendance/check-in";
const String checkOutUrl = "$url1/attendance/check-out";