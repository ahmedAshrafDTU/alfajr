import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerService {
  final SharedPreferences prefs;
  
  PrayerService(this.prefs);

  Future<PrayerTimes?> getPrayerTimes() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    Position position = await Geolocator.getCurrentPosition();
    final coordinates = Coordinates(position.latitude, position.longitude);
    
    // Configurable calculation method
    int methodIndex = prefs.getInt('prayer_calc_method') ?? 3; // default MuslimWorldLeague
    CalculationParameters params;
    switch(methodIndex) {
      case 1: params = CalculationMethod.karachi.getParameters(); break;
      case 2: params = CalculationMethod.umm_al_qura.getParameters(); break;
      case 3: params = CalculationMethod.muslim_world_league.getParameters(); break;
      case 4: params = CalculationMethod.egyptian.getParameters(); break;
      default: params = CalculationMethod.muslim_world_league.getParameters();
    }
    
    params.madhab = (prefs.getInt('asr_madhab') == 1) ? Madhab.hanafi : Madhab.shafi;

    return PrayerTimes.today(coordinates, params);
  }
}
