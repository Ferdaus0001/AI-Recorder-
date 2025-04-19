import 'package:rest_api/futures/presentaton/data/network/resposn/status_server.dart';

class ApiResponse<T>{
  StatusServer? static;
  T? data;
  String? message;
  ApiResponse(this.static,this.data,this.message);
  ApiResponse.loading():static = StatusServer.LOADING;
  ApiResponse.completed():static = StatusServer.LOADING;
  ApiResponse.error():static = StatusServer.LOADING;
  @override
String  toString(){
return 'Status:$static/n Message: $message\n $data';

}
}