import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('nl'),
    Locale('pt'),
  ];

  /// No description provided for @themeCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get themeCancel;

  /// No description provided for @themeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get themeConfirm;

  /// No description provided for @themeSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get themeSave;

  /// No description provided for @aboutTheBrowserCouldNotOpen.
  ///
  /// In en, this message translates to:
  /// **'The browser could not open the link. Copy the project link shown below.'**
  String get aboutTheBrowserCouldNotOpen;

  /// No description provided for @aboutCouldNotOpenTheBrowser.
  ///
  /// In en, this message translates to:
  /// **'Could not open the browser.'**
  String get aboutCouldNotOpenTheBrowser;

  /// No description provided for @aboutMitLicensedCode.
  ///
  /// In en, this message translates to:
  /// **'MIT-licensed code.'**
  String get aboutMitLicensedCode;

  /// No description provided for @aboutJoinTestingOrProposeAn.
  ///
  /// In en, this message translates to:
  /// **'Join testing or propose an improvement. Source code and roadmap are public.'**
  String get aboutJoinTestingOrProposeAn;

  /// No description provided for @aboutReportABug.
  ///
  /// In en, this message translates to:
  /// **'Report a bug'**
  String get aboutReportABug;

  /// No description provided for @aboutSuggestAnIdea.
  ///
  /// In en, this message translates to:
  /// **'Suggest an idea'**
  String get aboutSuggestAnIdea;

  /// No description provided for @qrCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get qrCode;

  /// No description provided for @qrJoinOnAmiludoCode.
  ///
  /// In en, this message translates to:
  /// **'Join “{title}” on amiLudo: {url} (code {code})'**
  String qrJoinOnAmiludoCode(Object title, Object url, Object code);

  /// No description provided for @qrShareLink.
  ///
  /// In en, this message translates to:
  /// **'Share link'**
  String get qrShareLink;

  /// No description provided for @qrCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get qrCodeCopied;

  /// No description provided for @qrCopyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get qrCopyCode;

  /// No description provided for @appearanceThemeImported.
  ///
  /// In en, this message translates to:
  /// **'Theme imported'**
  String get appearanceThemeImported;

  /// No description provided for @appearanceImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed'**
  String get appearanceImportFailed;

  /// No description provided for @appearance01YourWorld.
  ///
  /// In en, this message translates to:
  /// **'01 / Your world'**
  String get appearance01YourWorld;

  /// No description provided for @appearance02Light.
  ///
  /// In en, this message translates to:
  /// **'02 / Light'**
  String get appearance02Light;

  /// No description provided for @appearanceLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get appearanceLight;

  /// No description provided for @appearanceDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get appearanceDark;

  /// No description provided for @appearanceSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get appearanceSystem;

  /// No description provided for @appearance03Palette.
  ///
  /// In en, this message translates to:
  /// **'03 / Palette'**
  String get appearance03Palette;

  /// No description provided for @appearance04Typeface.
  ///
  /// In en, this message translates to:
  /// **'04 / Typeface'**
  String get appearance04Typeface;

  /// No description provided for @appearance05Shapes.
  ///
  /// In en, this message translates to:
  /// **'05 / Shapes'**
  String get appearance05Shapes;

  /// No description provided for @appearanceBeveled.
  ///
  /// In en, this message translates to:
  /// **'Beveled'**
  String get appearanceBeveled;

  /// No description provided for @appearanceSharp.
  ///
  /// In en, this message translates to:
  /// **'Sharp'**
  String get appearanceSharp;

  /// No description provided for @appearanceSoft.
  ///
  /// In en, this message translates to:
  /// **'Soft'**
  String get appearanceSoft;

  /// No description provided for @appearanceRounded.
  ///
  /// In en, this message translates to:
  /// **'Rounded'**
  String get appearanceRounded;

  /// No description provided for @appearance06Comfort.
  ///
  /// In en, this message translates to:
  /// **'06 / Comfort'**
  String get appearance06Comfort;

  /// No description provided for @appearance07YourProfiles.
  ///
  /// In en, this message translates to:
  /// **'07 / Your profiles'**
  String get appearance07YourProfiles;

  /// No description provided for @appearanceFontsAreBundledProfilesBelong.
  ///
  /// In en, this message translates to:
  /// **'Fonts are bundled. Profiles belong to this device and can be shared as files.'**
  String get appearanceFontsAreBundledProfilesBelong;

  /// No description provided for @appearanceYourWorldYourRules.
  ///
  /// In en, this message translates to:
  /// **'Your world / your rules'**
  String get appearanceYourWorldYourRules;

  /// No description provided for @appearanceMakeItYours.
  ///
  /// In en, this message translates to:
  /// **'Make it yours'**
  String get appearanceMakeItYours;

  /// No description provided for @appearanceFourWorldsElevenPalettesSeven.
  ///
  /// In en, this message translates to:
  /// **'Four worlds, eleven palettes, seven fonts. Saved on this device.'**
  String get appearanceFourWorldsElevenPalettesSeven;

  /// No description provided for @appearanceReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get appearanceReset;

  /// No description provided for @appearanceCompactLayout.
  ///
  /// In en, this message translates to:
  /// **'Compact layout'**
  String get appearanceCompactLayout;

  /// No description provided for @appearanceLargerText.
  ///
  /// In en, this message translates to:
  /// **'Larger text'**
  String get appearanceLargerText;

  /// No description provided for @appearanceAnimations.
  ///
  /// In en, this message translates to:
  /// **'Animations'**
  String get appearanceAnimations;

  /// No description provided for @appearanceAlertSounds.
  ///
  /// In en, this message translates to:
  /// **'Alert sounds'**
  String get appearanceAlertSounds;

  /// No description provided for @appearanceHapticFeedback.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get appearanceHapticFeedback;

  /// No description provided for @appearanceKeepScreenAwakeDuringGames.
  ///
  /// In en, this message translates to:
  /// **'Keep screen awake during games'**
  String get appearanceKeepScreenAwakeDuringGames;

  /// No description provided for @appearanceProfileName.
  ///
  /// In en, this message translates to:
  /// **'Profile name'**
  String get appearanceProfileName;

  /// No description provided for @appearanceSaveThisStyle.
  ///
  /// In en, this message translates to:
  /// **'Save this style'**
  String get appearanceSaveThisStyle;

  /// No description provided for @appearanceExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get appearanceExport;

  /// No description provided for @appearanceImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get appearanceImport;

  /// No description provided for @appearanceDeleteProfile.
  ///
  /// In en, this message translates to:
  /// **'Delete profile'**
  String get appearanceDeleteProfile;

  /// No description provided for @appearanceSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get appearanceSelected;

  /// No description provided for @appearanceChooseThisWorld.
  ///
  /// In en, this message translates to:
  /// **'Choose this world ↗'**
  String get appearanceChooseThisWorld;

  /// No description provided for @workspaceHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get workspaceHome;

  /// No description provided for @workspaceMyGame.
  ///
  /// In en, this message translates to:
  /// **'My game'**
  String get workspaceMyGame;

  /// No description provided for @workspaceTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get workspaceTools;

  /// No description provided for @workspaceShelf.
  ///
  /// In en, this message translates to:
  /// **'Shelf'**
  String get workspaceShelf;

  /// No description provided for @workspaceFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get workspaceFriends;

  /// No description provided for @workspaceNights.
  ///
  /// In en, this message translates to:
  /// **'Nights'**
  String get workspaceNights;

  /// No description provided for @workspaceHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get workspaceHistory;

  /// No description provided for @workspaceStyle.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get workspaceStyle;

  /// No description provided for @workspaceDataOnThisDevice.
  ///
  /// In en, this message translates to:
  /// **'● Data on this device'**
  String get workspaceDataOnThisDevice;

  /// No description provided for @workspaceAmiludoAlphaNoAccountNo.
  ///
  /// In en, this message translates to:
  /// **'amiLudo · Alpha\nNo account. No ads.'**
  String get workspaceAmiludoAlphaNoAccountNo;

  /// No description provided for @workspaceAboutAndFeedback.
  ///
  /// In en, this message translates to:
  /// **'About and feedback'**
  String get workspaceAboutAndFeedback;

  /// No description provided for @workspaceMyProfile.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get workspaceMyProfile;

  /// No description provided for @workspaceToggleLight.
  ///
  /// In en, this message translates to:
  /// **'Toggle light'**
  String get workspaceToggleLight;

  /// No description provided for @workspaceSavingFailedExportYourData.
  ///
  /// In en, this message translates to:
  /// **'Saving failed. Export your data before closing.'**
  String get workspaceSavingFailedExportYourData;

  /// No description provided for @workspaceRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get workspaceRetry;

  /// No description provided for @workspaceCheckTheNames40Characters.
  ///
  /// In en, this message translates to:
  /// **'Check the names (40 characters maximum).'**
  String get workspaceCheckTheNames40Characters;

  /// No description provided for @workspacePick1To32Different.
  ///
  /// In en, this message translates to:
  /// **'Pick 1 to 32 different names.'**
  String get workspacePick1To32Different;

  /// No description provided for @workspaceSetUpTheTable.
  ///
  /// In en, this message translates to:
  /// **'Set up the table'**
  String get workspaceSetUpTheTable;

  /// No description provided for @workspaceNewGame.
  ///
  /// In en, this message translates to:
  /// **'New game'**
  String get workspaceNewGame;

  /// No description provided for @workspaceWhoIsPlaying.
  ///
  /// In en, this message translates to:
  /// **'Who is playing?'**
  String get workspaceWhoIsPlaying;

  /// No description provided for @workspaceANameAPackYour.
  ///
  /// In en, this message translates to:
  /// **'A name, a pack, your players. The rest happens as you play.'**
  String get workspaceANameAPackYour;

  /// No description provided for @workspaceGameName.
  ///
  /// In en, this message translates to:
  /// **'Game name'**
  String get workspaceGameName;

  /// No description provided for @workspaceStartPlaying.
  ///
  /// In en, this message translates to:
  /// **'Start playing'**
  String get workspaceStartPlaying;

  /// No description provided for @workspaceYourGameContinues.
  ///
  /// In en, this message translates to:
  /// **'Your game continues'**
  String get workspaceYourGameContinues;

  /// No description provided for @workspaceToolsForYourTable.
  ///
  /// In en, this message translates to:
  /// **'Tools for your table'**
  String get workspaceToolsForYourTable;

  /// No description provided for @workspaceViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all ↗'**
  String get workspaceViewAll;

  /// No description provided for @workspaceRecentGoodTimes.
  ///
  /// In en, this message translates to:
  /// **'Recent good times'**
  String get workspaceRecentGoodTimes;

  /// No description provided for @workspaceHistory2.
  ///
  /// In en, this message translates to:
  /// **'History ↗'**
  String get workspaceHistory2;

  /// No description provided for @workspaceYourFirstGameAwaits.
  ///
  /// In en, this message translates to:
  /// **'Your first game awaits'**
  String get workspaceYourFirstGameAwaits;

  /// No description provided for @workspaceYourRealResultsWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Your real results will appear here.'**
  String get workspaceYourRealResultsWillAppear;

  /// No description provided for @workspacePlayTogetherStayInThe.
  ///
  /// In en, this message translates to:
  /// **'Play together / stay in the game'**
  String get workspacePlayTogetherStayInThe;

  /// No description provided for @workspaceWhatAreWePlayingToday.
  ///
  /// In en, this message translates to:
  /// **'What are we playing today?'**
  String get workspaceWhatAreWePlayingToday;

  /// No description provided for @workspaceTheRightToolsGoodCompany.
  ///
  /// In en, this message translates to:
  /// **'The right tools. Good company. Your actual games.'**
  String get workspaceTheRightToolsGoodCompany;

  /// No description provided for @workspaceGoodToolsGreatCompany.
  ///
  /// In en, this message translates to:
  /// **'Good tools. Great company.'**
  String get workspaceGoodToolsGreatCompany;

  /// No description provided for @workspaceYourFriendsYourTableLet.
  ///
  /// In en, this message translates to:
  /// **'Your friends, your table.\nLet’s play!'**
  String get workspaceYourFriendsYourTableLet;

  /// No description provided for @workspaceScoresChanceAndTimingKeep.
  ///
  /// In en, this message translates to:
  /// **'Scores, chance and timing:\nkeep your mind in the game.'**
  String get workspaceScoresChanceAndTimingKeep;

  /// No description provided for @workspaceFreeMode.
  ///
  /// In en, this message translates to:
  /// **'Free mode'**
  String get workspaceFreeMode;

  /// No description provided for @workspaceMyGameCompanions.
  ///
  /// In en, this message translates to:
  /// **'My game companions'**
  String get workspaceMyGameCompanions;

  /// No description provided for @workspaceOpenALobby.
  ///
  /// In en, this message translates to:
  /// **'Open a lobby'**
  String get workspaceOpenALobby;

  /// No description provided for @workspaceJoinAGame.
  ///
  /// In en, this message translates to:
  /// **'Join a game'**
  String get workspaceJoinAGame;

  /// No description provided for @workspaceResumeGame.
  ///
  /// In en, this message translates to:
  /// **'Resume game'**
  String get workspaceResumeGame;

  /// No description provided for @workspaceOpen.
  ///
  /// In en, this message translates to:
  /// **'Open ↗'**
  String get workspaceOpen;

  /// No description provided for @workspaceOpeningYourTable.
  ///
  /// In en, this message translates to:
  /// **'Opening your table…'**
  String get workspaceOpeningYourTable;

  /// No description provided for @workspaceCouldNotOpenYourLibrary.
  ///
  /// In en, this message translates to:
  /// **'Could not open your library'**
  String get workspaceCouldNotOpenYourLibrary;

  /// No description provided for @workspaceYourDataHasNotBeen.
  ///
  /// In en, this message translates to:
  /// **'Your data has not been overwritten. Check browser storage permissions and retry.'**
  String get workspaceYourDataHasNotBeen;

  /// No description provided for @appearanceLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get appearanceLanguageTitle;

  /// No description provided for @appearanceLanguageAuto.
  ///
  /// In en, this message translates to:
  /// **'Automatic (device)'**
  String get appearanceLanguageAuto;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'nl',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'nl':
      return AppLocalizationsNl();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
