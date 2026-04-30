// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Rick & Morty';

  @override
  String get characters => 'Characters';

  @override
  String get episodes => 'Episodes';

  @override
  String get locations => 'Locations';

  @override
  String get searchCharacters => 'Search characters...';

  @override
  String get searchEpisodes => 'Search episodes...';

  @override
  String get searchLocations => 'Search locations...';

  @override
  String get statusAlive => 'Alive';

  @override
  String get statusDead => 'Dead';

  @override
  String get statusUnknown => 'Unknown';

  @override
  String get noCharactersFound => 'No characters found';

  @override
  String get noEpisodesFound => 'No episodes found';

  @override
  String get noLocationsFound => 'No locations found';

  @override
  String get noResidentsFound => 'No residents found';

  @override
  String get information => 'Information';

  @override
  String get gender => 'Gender';

  @override
  String get origin => 'Origin';

  @override
  String get lastLocation => 'Last Location';

  @override
  String episodesCount(int count) {
    return 'Episodes ($count)';
  }

  @override
  String season(String num) {
    return 'Season $num';
  }

  @override
  String get residents => 'Residents';

  @override
  String residentsShowing(int total) {
    return 'Residents (showing 20 of $total)';
  }

  @override
  String get fieldType => 'Type';

  @override
  String get dimension => 'Dimension';

  @override
  String get charactersSection => 'Characters';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get darkTheme => 'Dark';

  @override
  String get lightTheme => 'Light';

  @override
  String get language => 'Language';

  @override
  String get langPortuguese => 'Portuguese';

  @override
  String get langEnglish => 'English';
}
