import 'package:xes1v1_mobile/controller/article_list_controller.dart';
import 'package:xes1v1_mobile/controller/example_controller.dart';
import 'package:xes1v1_mobile/controller/frame_list_controller.dart';

import 'base/result.dart';
import 'controller/article_controller.dart';
import 'controller/auth_mobile_controller.dart';
import 'controller/course_list_controller.dart';
import 'controller/frame_controller.dart';
import 'controller/honor_list_controller.dart';
import 'xes1v1_mobile.dart';

class Xes1v1MobileChannel extends ApplicationChannel {
  ManagedContext context;

  @override
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));

    final config = Xes1v1Configuration(options.configurationFilePath);
    context = contextWithConnectionInfo(config.database);
  }

  @override
  Controller get entryPoint {
    final router = Router(notFoundHandler: (request) async {
      await request.respond(Result.error("not data", 404));
      logger.info("${request.toDebugString()}");
    });

    router.route("/images/*").link(() => FileController('static/',
            onFileNotFound: (FileController controller, Request req) async {
          final file = File('static/page_not_found.jpg');
          final byteStream = file.openRead();
          return Response.ok(
            byteStream,
          )
            ..encodeBody = false
            ..contentType = ContentType("image", "jpeg");
        })
          ..addCachePolicy(
              const CachePolicy(expirationFromNow: Duration(days: 10)),
              (path) => path.endsWith('.jpg')));

    router
        .route("/example")
        .link(() => AuthMobileController())
        .link(() => ExampleController());

    router
        .route("/articleList")
//        .link(() => AuthMobileController())
        .link(() => ArticleListController(context));

    router
        .route("/article")
//        .link(() => AuthMobileController())
        .link(() => ArticleController(context));

    router
        .route("/frameList")
//        .link(() => AuthMobileController())
        .link(() => FrameListController(context));

    router
        .route("/frame")
//        .link(() => AuthMobileController())
        .link(() => FrameController(context));

    router
        .route("/courseList")
//        .link(() => AuthMobileController())
        .link(() => CourseListController(context));

    router
        .route("/honorList")
//        .link(() => AuthMobileController())
        .link(() => HonorListController(context));

    return router;
  }

  //初始化连接数据库
  ManagedContext contextWithConnectionInfo(
      DatabaseConfiguration connectionInfo) {
    final dataModel = ManagedDataModel.fromCurrentMirrorSystem();
    final psc = PostgreSQLPersistentStore(
        connectionInfo.username,
        connectionInfo.password,
        connectionInfo.host,
        connectionInfo.port,
        connectionInfo.databaseName);

    return ManagedContext(dataModel, psc);
  }
}

class Xes1v1Configuration extends Configuration {
  Xes1v1Configuration(String fileName) : super.fromFile(File(fileName));

  DatabaseConfiguration database;
}
