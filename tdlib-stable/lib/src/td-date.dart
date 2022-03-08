import 'package:intl/intl.dart';


/* ====================================================
	Created by andy pangaribuan on 2020/06/04
	Copyright CT Corp Digital. All rights reserved.
===================================================== */
class TDDate {

  final full = _DateUtil('yyyy-MM-dd HH:mm:ss');
  final fullMicro = _DateUtil("yyyy-MM-dd HH:mm:ss.SSSSSS");

  DateTime get nowUtc => DateTime.parse(DateTime.now().toUtc().toString().replaceAll("Z", "").replaceAll("z", ""));
  DateTime get now => DateTime.now();

  String toStr(String format, DateTime dt) {
    return _DateUtil(format).toStr(dt);
  }

  DateTime toDate(String format, String value) {
    return _DateUtil(format).toDate(value);
  }

}



class _DateUtil {

  String _format;
  DateFormat _dtFormat;

  _DateUtil(String format) {
    _format = format;
    _dtFormat = DateFormat(_format);
  }


  String toStr(DateTime dt) {
    switch (_format) {
      case "yyyy-MM-dd HH:mm:ss.SSSSSS":
        String date = dt.toIso8601String().replaceAll("T", " ").replaceAll("Z", "");
        final arr = date.split(".");
        if (arr.length == 1) {
          date += ".000000";
        } else if (arr[1].length != 6) {
          String ms = arr[1];
          while (ms.length != 6) {
            ms += "0";
          }
          date = date.replaceFirst("." + arr[1], "." + ms);
        }
        return date;
      default: return _dtFormat.format(dt);
    }
  }

  DateTime toDate(String dt) {
    if (_format == "yyyy-MM-dd HH:mm:ss.SSSSSS") {
      return DateTime.parse(dt.replaceAll(" ", "T"));
    }

    return _dtFormat.parse(dt);
  }

}
