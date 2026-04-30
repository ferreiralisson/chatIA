// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Rick & Morty';

  @override
  String get characters => 'Personagens';

  @override
  String get episodes => 'Episódios';

  @override
  String get locations => 'Localizações';

  @override
  String get searchCharacters => 'Buscar personagens...';

  @override
  String get searchEpisodes => 'Buscar episódios...';

  @override
  String get searchLocations => 'Buscar localizações...';

  @override
  String get statusAlive => 'Vivo';

  @override
  String get statusDead => 'Morto';

  @override
  String get statusUnknown => 'Desconhecido';

  @override
  String get noCharactersFound => 'Nenhum personagem encontrado';

  @override
  String get noEpisodesFound => 'Nenhum episódio encontrado';

  @override
  String get noLocationsFound => 'Nenhuma localização encontrada';

  @override
  String get noResidentsFound => 'Nenhum residente encontrado';

  @override
  String get information => 'Informações';

  @override
  String get gender => 'Gênero';

  @override
  String get origin => 'Origem';

  @override
  String get lastLocation => 'Última localização';

  @override
  String episodesCount(int count) {
    return 'Episódios ($count)';
  }

  @override
  String season(String num) {
    return 'Temporada $num';
  }

  @override
  String get residents => 'Residentes';

  @override
  String residentsShowing(int total) {
    return 'Residentes (mostrando 20 de $total)';
  }

  @override
  String get fieldType => 'Tipo';

  @override
  String get dimension => 'Dimensão';

  @override
  String get charactersSection => 'Personagens';

  @override
  String get settings => 'Configurações';

  @override
  String get theme => 'Tema';

  @override
  String get darkTheme => 'Escuro';

  @override
  String get lightTheme => 'Claro';

  @override
  String get language => 'Idioma';

  @override
  String get langPortuguese => 'Português';

  @override
  String get langEnglish => 'Inglês';
}
