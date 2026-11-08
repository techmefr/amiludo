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

  /// No description provided for @diceTrayView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get diceTrayView;

  /// No description provided for @diceTrayView2d.
  ///
  /// In en, this message translates to:
  /// **'2D'**
  String get diceTrayView2d;

  /// No description provided for @diceTrayView3d.
  ///
  /// In en, this message translates to:
  /// **'3D'**
  String get diceTrayView3d;

  /// No description provided for @appearanceDice3d.
  ///
  /// In en, this message translates to:
  /// **'3D dice'**
  String get appearanceDice3d;

  /// No description provided for @appearanceMotionSensors.
  ///
  /// In en, this message translates to:
  /// **'Motion sensors'**
  String get appearanceMotionSensors;

  /// No description provided for @appearanceSensorsOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get appearanceSensorsOff;

  /// No description provided for @appearanceSensorsLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get appearanceSensorsLow;

  /// No description provided for @appearanceSensorsMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get appearanceSensorsMedium;

  /// No description provided for @appearanceSensorsHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get appearanceSensorsHigh;

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

  /// No description provided for @appearanceSkinGameName.
  ///
  /// In en, this message translates to:
  /// **'Quest HUD'**
  String get appearanceSkinGameName;

  /// No description provided for @appearanceSkinGameDesc.
  ///
  /// In en, this message translates to:
  /// **'Dark and gold, framed panels, a game-HUD feel.'**
  String get appearanceSkinGameDesc;

  /// No description provided for @appearanceHudPreview.
  ///
  /// In en, this message translates to:
  /// **'Progress bar preview'**
  String get appearanceHudPreview;

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

  /// No description provided for @randomRedBlueGreenRedBlue.
  ///
  /// In en, this message translates to:
  /// **'Red, Blue, Green, Red, Blue'**
  String get randomRedBlueGreenRedBlue;

  /// No description provided for @randomCommaSeparatedOptions.
  ///
  /// In en, this message translates to:
  /// **'Comma-separated options'**
  String get randomCommaSeparatedOptions;

  /// No description provided for @randomRepeatedEntriesRepresentSeveralTokens.
  ///
  /// In en, this message translates to:
  /// **'Repeated entries represent several tokens.'**
  String get randomRepeatedEntriesRepresentSeveralTokens;

  /// No description provided for @randomTokensRemaining.
  ///
  /// In en, this message translates to:
  /// **'tokens remaining'**
  String get randomTokensRemaining;

  /// No description provided for @randomRefillBag.
  ///
  /// In en, this message translates to:
  /// **'Refill bag'**
  String get randomRefillBag;

  /// No description provided for @randomImportFailedIncompatibleSheet.
  ///
  /// In en, this message translates to:
  /// **'Import failed: incompatible sheet'**
  String get randomImportFailedIncompatibleSheet;

  /// No description provided for @randomReplaceThisSheet.
  ///
  /// In en, this message translates to:
  /// **'Replace this sheet?'**
  String get randomReplaceThisSheet;

  /// No description provided for @randomSheetImported.
  ///
  /// In en, this message translates to:
  /// **'Sheet imported'**
  String get randomSheetImported;

  /// No description provided for @randomImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {e}'**
  String randomImportFailed(Object e);

  /// No description provided for @randomMyCharacters.
  ///
  /// In en, this message translates to:
  /// **'My characters'**
  String get randomMyCharacters;

  /// No description provided for @randomImportAJsonSheet.
  ///
  /// In en, this message translates to:
  /// **'Import a JSON sheet'**
  String get randomImportAJsonSheet;

  /// No description provided for @randomYourSavedCharactersWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Your saved characters will appear here, even if their pack is deleted.'**
  String get randomYourSavedCharactersWillAppear;

  /// No description provided for @randomDeleteThisCharacter.
  ///
  /// In en, this message translates to:
  /// **'Delete this character?'**
  String get randomDeleteThisCharacter;

  /// No description provided for @randomExportTheSheet.
  ///
  /// In en, this message translates to:
  /// **'Export the sheet'**
  String get randomExportTheSheet;

  /// No description provided for @randomDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get randomDelete;

  /// No description provided for @randomRestartCreation.
  ///
  /// In en, this message translates to:
  /// **'Restart creation?'**
  String get randomRestartCreation;

  /// No description provided for @randomCurrentChoicesWillBeDiscarded.
  ///
  /// In en, this message translates to:
  /// **'Current choices will be discarded. Saved sheets are kept.'**
  String get randomCurrentChoicesWillBeDiscarded;

  /// No description provided for @randomList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get randomList;

  /// No description provided for @randomPacks.
  ///
  /// In en, this message translates to:
  /// **'Packs'**
  String get randomPacks;

  /// No description provided for @randomCardsPerPackKeepTo.
  ///
  /// In en, this message translates to:
  /// **'{name} · {count} cards · {draw} per pack · keep {keepMin} to {keepMax}'**
  String randomCardsPerPackKeepTo(
    Object name,
    Object count,
    Object draw,
    Object keepMin,
    Object keepMax,
  );

  /// No description provided for @randomGenerateMyCharacter.
  ///
  /// In en, this message translates to:
  /// **'Generate my character'**
  String get randomGenerateMyCharacter;

  /// No description provided for @randomStep.
  ///
  /// In en, this message translates to:
  /// **'STEP'**
  String get randomStep;

  /// No description provided for @randomCreateTheSheet.
  ///
  /// In en, this message translates to:
  /// **'Create the sheet'**
  String get randomCreateTheSheet;

  /// No description provided for @randomConfirmAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Confirm and continue'**
  String get randomConfirmAndContinue;

  /// No description provided for @randomYourCharacter.
  ///
  /// In en, this message translates to:
  /// **'Your character'**
  String get randomYourCharacter;

  /// No description provided for @randomCharacterName.
  ///
  /// In en, this message translates to:
  /// **'Character name'**
  String get randomCharacterName;

  /// No description provided for @randomGiveTheCharacterAName.
  ///
  /// In en, this message translates to:
  /// **'Give the character a name.'**
  String get randomGiveTheCharacterAName;

  /// No description provided for @randomCharacterSaved.
  ///
  /// In en, this message translates to:
  /// **'Character saved'**
  String get randomCharacterSaved;

  /// No description provided for @randomSaveTheSheet.
  ///
  /// In en, this message translates to:
  /// **'Save the sheet'**
  String get randomSaveTheSheet;

  /// No description provided for @randomBuildYourCharacterByOpening.
  ///
  /// In en, this message translates to:
  /// **'Build your character by opening one pack per card type. Selection limits are set by its creator.'**
  String get randomBuildYourCharacterByOpening;

  /// No description provided for @randomRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get randomRestart;

  /// No description provided for @randomHeads.
  ///
  /// In en, this message translates to:
  /// **'HEADS'**
  String get randomHeads;

  /// No description provided for @randomTails.
  ///
  /// In en, this message translates to:
  /// **'TAILS'**
  String get randomTails;

  /// No description provided for @randomCount.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get randomCount;

  /// No description provided for @randomCommaSeparatedSymbols.
  ///
  /// In en, this message translates to:
  /// **'Comma-separated symbols'**
  String get randomCommaSeparatedSymbols;

  /// No description provided for @randomExpression2d63D204d8.
  ///
  /// In en, this message translates to:
  /// **'Expression: 2d6+3, d20, 4d8-2'**
  String get randomExpression2d63D204d8;

  /// No description provided for @randomEvaluate.
  ///
  /// In en, this message translates to:
  /// **'Evaluate'**
  String get randomEvaluate;

  /// No description provided for @randomRollTheDice.
  ///
  /// In en, this message translates to:
  /// **'Roll the dice'**
  String get randomRollTheDice;

  /// No description provided for @randomCustomSymbols.
  ///
  /// In en, this message translates to:
  /// **'Custom symbols'**
  String get randomCustomSymbols;

  /// No description provided for @randomPressTheButtonToRoll.
  ///
  /// In en, this message translates to:
  /// **'Press the button to roll.'**
  String get randomPressTheButtonToRoll;

  /// No description provided for @randomRollDice.
  ///
  /// In en, this message translates to:
  /// **'Roll dice'**
  String get randomRollDice;

  /// No description provided for @randomTapADieToKeep.
  ///
  /// In en, this message translates to:
  /// **'Tap a die to keep it on the next roll.'**
  String get randomTapADieToKeep;

  /// No description provided for @randomRecentRolls.
  ///
  /// In en, this message translates to:
  /// **'RECENT ROLLS'**
  String get randomRecentRolls;

  /// No description provided for @randomTheChosenContactIsHighlighted.
  ///
  /// In en, this message translates to:
  /// **'The chosen contact is highlighted.'**
  String get randomTheChosenContactIsHighlighted;

  /// No description provided for @randomPlaceYourFingersHere.
  ///
  /// In en, this message translates to:
  /// **'PLACE YOUR FINGERS HERE'**
  String get randomPlaceYourFingersHere;

  /// No description provided for @randomChoosing.
  ///
  /// In en, this message translates to:
  /// **'Choosing…'**
  String get randomChoosing;

  /// No description provided for @randomHoldYourFingersOnThe.
  ///
  /// In en, this message translates to:
  /// **'Hold your fingers on the area: one is chosen after 1.6 seconds. Contact limit depends on your screen.'**
  String get randomHoldYourFingersOnThe;

  /// No description provided for @randomOrPickANameWithout.
  ///
  /// In en, this message translates to:
  /// **'Or pick a name without multi-touch.'**
  String get randomOrPickANameWithout;

  /// No description provided for @randomPickAPlayer.
  ///
  /// In en, this message translates to:
  /// **'Pick a player'**
  String get randomPickAPlayer;

  /// No description provided for @randomMinimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get randomMinimum;

  /// No description provided for @randomMaximum.
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get randomMaximum;

  /// No description provided for @randomParticipants.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get randomParticipants;

  /// No description provided for @randomCardsToReveal.
  ///
  /// In en, this message translates to:
  /// **'{draw} cards to reveal'**
  String randomCardsToReveal(Object draw);

  /// No description provided for @randomOpenThePack.
  ///
  /// In en, this message translates to:
  /// **'Open the pack · {name}'**
  String randomOpenThePack(Object name);

  /// No description provided for @randomRevealAll.
  ///
  /// In en, this message translates to:
  /// **'Reveal all'**
  String get randomRevealAll;

  /// No description provided for @randomEnterTwoWholeNumbersThe.
  ///
  /// In en, this message translates to:
  /// **'Enter two whole numbers, the minimum before the maximum.'**
  String get randomEnterTwoWholeNumbersThe;

  /// No description provided for @randomTheBagIsEmptyRefill.
  ///
  /// In en, this message translates to:
  /// **'The bag is empty. Refill it to start again.'**
  String get randomTheBagIsEmptyRefill;

  /// No description provided for @randomProvideExactlyOneRolePer.
  ///
  /// In en, this message translates to:
  /// **'Provide exactly one role per player.'**
  String get randomProvideExactlyOneRolePer;

  /// No description provided for @randomPickBetween2And50.
  ///
  /// In en, this message translates to:
  /// **'Pick between 2 and 50 options.'**
  String get randomPickBetween2And50;

  /// No description provided for @randomWeightAWholeNumberFrom.
  ///
  /// In en, this message translates to:
  /// **'Weight: a whole number from 1 to 1,000,000.'**
  String get randomWeightAWholeNumberFrom;

  /// No description provided for @randomDraw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get randomDraw;

  /// No description provided for @randomWerewolf.
  ///
  /// In en, this message translates to:
  /// **'Werewolf'**
  String get randomWerewolf;

  /// No description provided for @randomVillager.
  ///
  /// In en, this message translates to:
  /// **'Villager'**
  String get randomVillager;

  /// No description provided for @randomAllRolesHaveBeenAssigned.
  ///
  /// In en, this message translates to:
  /// **'All roles have been assigned.'**
  String get randomAllRolesHaveBeenAssigned;

  /// No description provided for @randomOneRolePerPlayerComma.
  ///
  /// In en, this message translates to:
  /// **'One role per player, comma separated'**
  String get randomOneRolePerPlayerComma;

  /// No description provided for @randomAssignRoles.
  ///
  /// In en, this message translates to:
  /// **'Assign roles'**
  String get randomAssignRoles;

  /// No description provided for @randomPassTheDeviceTo.
  ///
  /// In en, this message translates to:
  /// **'Pass the device to'**
  String get randomPassTheDeviceTo;

  /// No description provided for @randomHideAndPass.
  ///
  /// In en, this message translates to:
  /// **'Hide and pass'**
  String get randomHideAndPass;

  /// No description provided for @randomRevealMyRole.
  ///
  /// In en, this message translates to:
  /// **'Reveal my role'**
  String get randomRevealMyRole;

  /// No description provided for @randomEachFingerShowsItsTeam.
  ///
  /// In en, this message translates to:
  /// **'Each finger shows its team colour and number.'**
  String get randomEachFingerShowsItsTeam;

  /// No description provided for @randomEveryonePutAFingerDown.
  ///
  /// In en, this message translates to:
  /// **'EVERYONE PUT A FINGER DOWN (at least {teamCount})'**
  String randomEveryonePutAFingerDown(Object teamCount);

  /// No description provided for @randomSplitting.
  ///
  /// In en, this message translates to:
  /// **'Splitting…'**
  String get randomSplitting;

  /// No description provided for @randomAtLeastTwoPlayersAre.
  ///
  /// In en, this message translates to:
  /// **'At least two players are needed.'**
  String get randomAtLeastTwoPlayersAre;

  /// No description provided for @randomNames.
  ///
  /// In en, this message translates to:
  /// **'Names'**
  String get randomNames;

  /// No description provided for @randomLobby.
  ///
  /// In en, this message translates to:
  /// **'Lobby'**
  String get randomLobby;

  /// No description provided for @randomFingers.
  ///
  /// In en, this message translates to:
  /// **'Fingers'**
  String get randomFingers;

  /// No description provided for @randomLobbyPlayers.
  ///
  /// In en, this message translates to:
  /// **'Lobby players: {value}'**
  String randomLobbyPlayers(Object value);

  /// No description provided for @randomNamesCommaSeparated.
  ///
  /// In en, this message translates to:
  /// **'Names, comma separated'**
  String get randomNamesCommaSeparated;

  /// No description provided for @randomMakeTeams.
  ///
  /// In en, this message translates to:
  /// **'Make teams'**
  String get randomMakeTeams;

  /// No description provided for @randomTeams.
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get randomTeams;

  /// No description provided for @randomOneTeamLess.
  ///
  /// In en, this message translates to:
  /// **'One team less'**
  String get randomOneTeamLess;

  /// No description provided for @randomOneMoreTeam.
  ///
  /// In en, this message translates to:
  /// **'One more team'**
  String get randomOneMoreTeam;

  /// No description provided for @randomTeam.
  ///
  /// In en, this message translates to:
  /// **'Team {value}'**
  String randomTeam(Object value);

  /// No description provided for @randomInstallACharacterPackFrom.
  ///
  /// In en, this message translates to:
  /// **'Install a character pack from the gallery, or create your categories in the builder.'**
  String get randomInstallACharacterPackFrom;

  /// No description provided for @randomGameSetup.
  ///
  /// In en, this message translates to:
  /// **'Game setup'**
  String get randomGameSetup;

  /// No description provided for @randomFreeTool.
  ///
  /// In en, this message translates to:
  /// **'Free tool'**
  String get randomFreeTool;

  /// No description provided for @randomOpenTheBuilder.
  ///
  /// In en, this message translates to:
  /// **'Open the builder'**
  String get randomOpenTheBuilder;

  /// No description provided for @randomFindAPack.
  ///
  /// In en, this message translates to:
  /// **'Find a pack'**
  String get randomFindAPack;

  /// No description provided for @randomToolNotFound.
  ///
  /// In en, this message translates to:
  /// **'Tool not found'**
  String get randomToolNotFound;

  /// No description provided for @randomGoBackToTheToolbox.
  ///
  /// In en, this message translates to:
  /// **'Go back to the toolbox.'**
  String get randomGoBackToTheToolbox;

  /// No description provided for @randomFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get randomFavorite;

  /// No description provided for @randomYourToolboxWithinReach.
  ///
  /// In en, this message translates to:
  /// **'Your toolbox / within reach'**
  String get randomYourToolboxWithinReach;

  /// No description provided for @randomOneToolReadyToPlay.
  ///
  /// In en, this message translates to:
  /// **'One tool. Ready to play.'**
  String get randomOneToolReadyToPlay;

  /// No description provided for @randomPlayersAreSharedAcrossTools.
  ///
  /// In en, this message translates to:
  /// **'Players are shared across tools. Random draws use the system secure generator.'**
  String get randomPlayersAreSharedAcrossTools;

  /// No description provided for @randomWeightsAffectTheDrawNot.
  ///
  /// In en, this message translates to:
  /// **'Weights affect the draw, not sector sizes.'**
  String get randomWeightsAffectTheDrawNot;

  /// No description provided for @randomOptionalWeightsCamille2Alex.
  ///
  /// In en, this message translates to:
  /// **'Optional weights: Camille:2, Alex:1'**
  String get randomOptionalWeightsCamille2Alex;

  /// No description provided for @templatesPackNotFound.
  ///
  /// In en, this message translates to:
  /// **'Pack not found'**
  String get templatesPackNotFound;

  /// No description provided for @templatesThisPackIsNoLonger.
  ///
  /// In en, this message translates to:
  /// **'This pack is no longer installed.'**
  String get templatesThisPackIsNoLonger;

  /// No description provided for @templatesCopy.
  ///
  /// In en, this message translates to:
  /// **'copy'**
  String get templatesCopy;

  /// No description provided for @templatesThePackWillBeCopied.
  ///
  /// In en, this message translates to:
  /// **'The pack will be copied to this device.'**
  String get templatesThePackWillBeCopied;

  /// No description provided for @templatesLocalChangesToThisPack.
  ///
  /// In en, this message translates to:
  /// **'Local changes to this pack will be replaced. Export them to keep them.'**
  String get templatesLocalChangesToThisPack;

  /// No description provided for @templatesInstallThisPack.
  ///
  /// In en, this message translates to:
  /// **'Install this pack?'**
  String get templatesInstallThisPack;

  /// No description provided for @templatesReplaceTheLocalPack.
  ///
  /// In en, this message translates to:
  /// **'Replace the local pack?'**
  String get templatesReplaceTheLocalPack;

  /// No description provided for @templatesPackInstalledFindItIn.
  ///
  /// In en, this message translates to:
  /// **'Pack installed. Find it in your templates.'**
  String get templatesPackInstalledFindItIn;

  /// No description provided for @templatesCommunityGallery.
  ///
  /// In en, this message translates to:
  /// **'Community gallery'**
  String get templatesCommunityGallery;

  /// No description provided for @templatesSearchAGameAPack.
  ///
  /// In en, this message translates to:
  /// **'Search a game, a pack or an author'**
  String get templatesSearchAGameAPack;

  /// No description provided for @templatesNoPackForThisSearch.
  ///
  /// In en, this message translates to:
  /// **'No pack for this search.'**
  String get templatesNoPackForThisSearch;

  /// No description provided for @templatesAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get templatesAll;

  /// No description provided for @templatesDice.
  ///
  /// In en, this message translates to:
  /// **'Dice'**
  String get templatesDice;

  /// No description provided for @templatesRoles.
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get templatesRoles;

  /// No description provided for @templatesScores.
  ///
  /// In en, this message translates to:
  /// **'Scores'**
  String get templatesScores;

  /// No description provided for @templatesCharacters.
  ///
  /// In en, this message translates to:
  /// **'Characters'**
  String get templatesCharacters;

  /// No description provided for @templatesCatalogueUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Catalogue unavailable.'**
  String get templatesCatalogueUnavailable;

  /// No description provided for @templatesCouldNotRefreshInstalledPacks.
  ///
  /// In en, this message translates to:
  /// **'Could not refresh. Installed packs stay available offline.'**
  String get templatesCouldNotRefreshInstalledPacks;

  /// No description provided for @templatesCreateSharePlay.
  ///
  /// In en, this message translates to:
  /// **'CREATE / SHARE / PLAY'**
  String get templatesCreateSharePlay;

  /// No description provided for @templatesToolsAreMadeToBe.
  ///
  /// In en, this message translates to:
  /// **'Tools are made to be shared'**
  String get templatesToolsAreMadeToBe;

  /// No description provided for @templatesInstallAPackCustomiseIt.
  ///
  /// In en, this message translates to:
  /// **'Install a pack, customise it and play offline. The catalogue starts with original examples; contributions are reviewed on the public repository.'**
  String get templatesInstallAPackCustomiseIt;

  /// No description provided for @templatesPublicCatalogueRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Public catalogue refreshed'**
  String get templatesPublicCatalogueRefreshed;

  /// No description provided for @templatesCatalogueBundledWithTheApp.
  ///
  /// In en, this message translates to:
  /// **'Catalogue bundled with the app. Refresh to discover new contributions.'**
  String get templatesCatalogueBundledWithTheApp;

  /// No description provided for @templatesRefreshTheGallery.
  ///
  /// In en, this message translates to:
  /// **'Refresh the gallery'**
  String get templatesRefreshTheGallery;

  /// No description provided for @templatesCreateMyPack.
  ///
  /// In en, this message translates to:
  /// **'Create my pack'**
  String get templatesCreateMyPack;

  /// No description provided for @templatesHowToPublishMyPack.
  ///
  /// In en, this message translates to:
  /// **'How to publish my pack?'**
  String get templatesHowToPublishMyPack;

  /// No description provided for @templatesDiceTypesRolesCategoriesBoosters.
  ///
  /// In en, this message translates to:
  /// **'{count} dice types · {count2} roles · {count3} categories · {count4} boosters'**
  String templatesDiceTypesRolesCategoriesBoosters(
    Object count,
    Object count2,
    Object count3,
    Object count4,
  );

  /// No description provided for @templatesReferenceRules.
  ///
  /// In en, this message translates to:
  /// **'Reference rules'**
  String get templatesReferenceRules;

  /// No description provided for @templatesReinstallReplace.
  ///
  /// In en, this message translates to:
  /// **'Reinstall / replace'**
  String get templatesReinstallReplace;

  /// No description provided for @templatesInstallThePack.
  ///
  /// In en, this message translates to:
  /// **'Install the pack'**
  String get templatesInstallThePack;

  /// No description provided for @templatesOpenMyPack.
  ///
  /// In en, this message translates to:
  /// **'Open my pack'**
  String get templatesOpenMyPack;

  /// No description provided for @templatesPackSavedOnThisDevice.
  ///
  /// In en, this message translates to:
  /// **'Pack saved on this device'**
  String get templatesPackSavedOnThisDevice;

  /// No description provided for @templatesCheckTheNumbersAndFields.
  ///
  /// In en, this message translates to:
  /// **'Check the numbers and fields of the pack.'**
  String get templatesCheckTheNumbersAndFields;

  /// No description provided for @templatesFillInTheGameName.
  ///
  /// In en, this message translates to:
  /// **'Fill in the game name and its English name.'**
  String get templatesFillInTheGameName;

  /// No description provided for @templatesPickAtLeastOneTool.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one tool.'**
  String get templatesPickAtLeastOneTool;

  /// No description provided for @templatesGameOrPackName.
  ///
  /// In en, this message translates to:
  /// **'Game or pack name'**
  String get templatesGameOrPackName;

  /// No description provided for @templatesEnglishGameName.
  ///
  /// In en, this message translates to:
  /// **'English game name'**
  String get templatesEnglishGameName;

  /// No description provided for @templatesDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get templatesDescription;

  /// No description provided for @templatesEditionOrVariant.
  ///
  /// In en, this message translates to:
  /// **'Edition or variant'**
  String get templatesEditionOrVariant;

  /// No description provided for @templatesPackLanguageFrEn.
  ///
  /// In en, this message translates to:
  /// **'Pack language (fr, en…)'**
  String get templatesPackLanguageFrEn;

  /// No description provided for @templatesTurnTimeInSeconds.
  ///
  /// In en, this message translates to:
  /// **'Turn time in seconds'**
  String get templatesTurnTimeInSeconds;

  /// No description provided for @templatesCounters.
  ///
  /// In en, this message translates to:
  /// **'counters'**
  String get templatesCounters;

  /// No description provided for @templatesGame.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get templatesGame;

  /// No description provided for @templatesModes.
  ///
  /// In en, this message translates to:
  /// **'Modes'**
  String get templatesModes;

  /// No description provided for @templatesPoints.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get templatesPoints;

  /// No description provided for @templatesCounters2.
  ///
  /// In en, this message translates to:
  /// **'Counters'**
  String get templatesCounters2;

  /// No description provided for @templatesBricks.
  ///
  /// In en, this message translates to:
  /// **'Bricks'**
  String get templatesBricks;

  /// No description provided for @brickLife.
  ///
  /// In en, this message translates to:
  /// **'Life'**
  String get brickLife;

  /// No description provided for @brickPoints.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get brickPoints;

  /// No description provided for @brickChips.
  ///
  /// In en, this message translates to:
  /// **'Chips'**
  String get brickChips;

  /// No description provided for @brickPot.
  ///
  /// In en, this message translates to:
  /// **'Pot'**
  String get brickPot;

  /// No description provided for @templatesTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get templatesTime;

  /// No description provided for @templatesRules.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get templatesRules;

  /// No description provided for @templatesSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get templatesSummary;

  /// No description provided for @templatesLeaveTheBuilder.
  ///
  /// In en, this message translates to:
  /// **'Leave the builder?'**
  String get templatesLeaveTheBuilder;

  /// No description provided for @templatesUnsavedChangesWillBeLost.
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes will be lost.'**
  String get templatesUnsavedChangesWillBeLost;

  /// No description provided for @templatesCreateAGamePack.
  ///
  /// In en, this message translates to:
  /// **'Create a game pack'**
  String get templatesCreateAGamePack;

  /// No description provided for @templatesEditThePack.
  ///
  /// In en, this message translates to:
  /// **'Edit the pack'**
  String get templatesEditThePack;

  /// No description provided for @templatesWorkshopYourGame.
  ///
  /// In en, this message translates to:
  /// **'WORKSHOP / YOUR GAME'**
  String get templatesWorkshopYourGame;

  /// No description provided for @templatesOneGameYourTools.
  ///
  /// In en, this message translates to:
  /// **'One game, your tools'**
  String get templatesOneGameYourTools;

  /// No description provided for @templatesBuildTheDiceRolesAnd.
  ///
  /// In en, this message translates to:
  /// **'Build the dice, roles and scoring. Save, test, then share your pack.'**
  String get templatesBuildTheDiceRolesAnd;

  /// No description provided for @templatesStep.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get templatesStep;

  /// No description provided for @templatesContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get templatesContinue;

  /// No description provided for @templatesPreviousStep.
  ///
  /// In en, this message translates to:
  /// **'Previous step'**
  String get templatesPreviousStep;

  /// No description provided for @templatesSaveThePack.
  ///
  /// In en, this message translates to:
  /// **'Save the pack'**
  String get templatesSaveThePack;

  /// No description provided for @templates01GameDice.
  ///
  /// In en, this message translates to:
  /// **'01 / Game dice'**
  String get templates01GameDice;

  /// No description provided for @templatesSetTheLabelAndValue.
  ///
  /// In en, this message translates to:
  /// **'Set the label and value of each face. Repeat a face to make it more frequent. Each type can have several copies.'**
  String get templatesSetTheLabelAndValue;

  /// No description provided for @templatesAddADie.
  ///
  /// In en, this message translates to:
  /// **'Add a die'**
  String get templatesAddADie;

  /// No description provided for @templatesDieName.
  ///
  /// In en, this message translates to:
  /// **'Die name'**
  String get templatesDieName;

  /// No description provided for @templatesNumberOfCopies.
  ///
  /// In en, this message translates to:
  /// **'Number of copies'**
  String get templatesNumberOfCopies;

  /// No description provided for @templatesFaceSymbol.
  ///
  /// In en, this message translates to:
  /// **'Face / symbol'**
  String get templatesFaceSymbol;

  /// No description provided for @templatesValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get templatesValue;

  /// No description provided for @templatesRemoveTheFace.
  ///
  /// In en, this message translates to:
  /// **'Remove the face'**
  String get templatesRemoveTheFace;

  /// No description provided for @templatesAddAFace.
  ///
  /// In en, this message translates to:
  /// **'Add a face'**
  String get templatesAddAFace;

  /// No description provided for @templatesRemoveThisDie.
  ///
  /// In en, this message translates to:
  /// **'Remove this die'**
  String get templatesRemoveThisDie;

  /// No description provided for @templates02GameRoles.
  ///
  /// In en, this message translates to:
  /// **'02 / Game roles'**
  String get templates02GameRoles;

  /// No description provided for @templatesPickHowManyCardsEach.
  ///
  /// In en, this message translates to:
  /// **'Pick how many cards each role has. Dealing needs exactly as many cards as players.'**
  String get templatesPickHowManyCardsEach;

  /// No description provided for @templatesAddARole.
  ///
  /// In en, this message translates to:
  /// **'Add a role'**
  String get templatesAddARole;

  /// No description provided for @templatesRoleName.
  ///
  /// In en, this message translates to:
  /// **'Role name'**
  String get templatesRoleName;

  /// No description provided for @templatesNumberOfCards.
  ///
  /// In en, this message translates to:
  /// **'Number of cards'**
  String get templatesNumberOfCards;

  /// No description provided for @templatesPowerGoalOrPrivateInstruction.
  ///
  /// In en, this message translates to:
  /// **'Power, goal or private instruction'**
  String get templatesPowerGoalOrPrivateInstruction;

  /// No description provided for @templatesRemoveThisRole.
  ///
  /// In en, this message translates to:
  /// **'Remove this role'**
  String get templatesRemoveThisRole;

  /// No description provided for @templates04CharactersAndBoosters.
  ///
  /// In en, this message translates to:
  /// **'04 / Characters and boosters'**
  String get templates04CharactersAndBoosters;

  /// No description provided for @templatesCreateYourCategoriesRacesJobs.
  ///
  /// In en, this message translates to:
  /// **'Create your categories: races, jobs, backstories, powers… In list mode, every card is offered. In booster mode, only drawn cards are revealed. The minimum and maximum of kept cards apply to both modes.'**
  String get templatesCreateYourCategoriesRacesJobs;

  /// No description provided for @templatesAddACharacterCategory.
  ///
  /// In en, this message translates to:
  /// **'Add a character category'**
  String get templatesAddACharacterCategory;

  /// No description provided for @templatesCharacterCategory.
  ///
  /// In en, this message translates to:
  /// **'Character category'**
  String get templatesCharacterCategory;

  /// No description provided for @templatesCardsOfferedPerBooster.
  ///
  /// In en, this message translates to:
  /// **'Cards offered per booster'**
  String get templatesCardsOfferedPerBooster;

  /// No description provided for @templatesMinimumCardsToKeep.
  ///
  /// In en, this message translates to:
  /// **'Minimum cards to keep'**
  String get templatesMinimumCardsToKeep;

  /// No description provided for @templatesMaximumCardsToKeep.
  ///
  /// In en, this message translates to:
  /// **'Maximum cards to keep'**
  String get templatesMaximumCardsToKeep;

  /// No description provided for @templatesCardName.
  ///
  /// In en, this message translates to:
  /// **'Card name'**
  String get templatesCardName;

  /// No description provided for @templatesDescriptionEffectOrStory.
  ///
  /// In en, this message translates to:
  /// **'Description, effect or story'**
  String get templatesDescriptionEffectOrStory;

  /// No description provided for @templatesRemoveTheCard.
  ///
  /// In en, this message translates to:
  /// **'Remove the card'**
  String get templatesRemoveTheCard;

  /// No description provided for @templatesAddACard.
  ///
  /// In en, this message translates to:
  /// **'Add a card'**
  String get templatesAddACard;

  /// No description provided for @templatesRemoveThisCharacterCategory.
  ///
  /// In en, this message translates to:
  /// **'Remove this character category'**
  String get templatesRemoveThisCharacterCategory;

  /// No description provided for @templatesPlayerCounters.
  ///
  /// In en, this message translates to:
  /// **'Player counters'**
  String get templatesPlayerCounters;

  /// No description provided for @templatesLivesEnergyCombatPointsEach.
  ///
  /// In en, this message translates to:
  /// **'Lives, energy, combat points… Each player starts with these values and adjusts them during the game.'**
  String get templatesLivesEnergyCombatPointsEach;

  /// No description provided for @templatesAddACounter.
  ///
  /// In en, this message translates to:
  /// **'Add a counter'**
  String get templatesAddACounter;

  /// No description provided for @templatesCounterName.
  ///
  /// In en, this message translates to:
  /// **'Counter name'**
  String get templatesCounterName;

  /// No description provided for @templatesStartingValue.
  ///
  /// In en, this message translates to:
  /// **'Starting value'**
  String get templatesStartingValue;

  /// No description provided for @templatesRemoveThisCounter.
  ///
  /// In en, this message translates to:
  /// **'Remove this counter'**
  String get templatesRemoveThisCounter;

  /// No description provided for @templatesStackableStatuses.
  ///
  /// In en, this message translates to:
  /// **'Stackable statuses'**
  String get templatesStackableStatuses;

  /// No description provided for @templatesPoisonShieldStunnedPlayersStack.
  ///
  /// In en, this message translates to:
  /// **'Poison, shield, stunned… Players stack or remove status tokens during the game.'**
  String get templatesPoisonShieldStunnedPlayersStack;

  /// No description provided for @templatesAddAStatus.
  ///
  /// In en, this message translates to:
  /// **'Add a status'**
  String get templatesAddAStatus;

  /// No description provided for @templatesStatusName.
  ///
  /// In en, this message translates to:
  /// **'Status name'**
  String get templatesStatusName;

  /// No description provided for @templatesRemoveThisStatus.
  ///
  /// In en, this message translates to:
  /// **'Remove this status'**
  String get templatesRemoveThisStatus;

  /// No description provided for @templatesThisPackIsNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'This pack is not installed on this device.'**
  String get templatesThisPackIsNotInstalled;

  /// No description provided for @templatesPackSheet.
  ///
  /// In en, this message translates to:
  /// **'Pack sheet'**
  String get templatesPackSheet;

  /// No description provided for @templatesRulesCopyKeptForThis.
  ///
  /// In en, this message translates to:
  /// **'Rules copy kept for this game.'**
  String get templatesRulesCopyKeptForThis;

  /// No description provided for @templatesUnknownAuthor.
  ///
  /// In en, this message translates to:
  /// **'Unknown author'**
  String get templatesUnknownAuthor;

  /// No description provided for @templatesShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get templatesShare;

  /// No description provided for @templatesTheFileHoldsThePack.
  ///
  /// In en, this message translates to:
  /// **'The file holds the pack dice, roles, scoring and notes. It does not hold your games.'**
  String get templatesTheFileHoldsThePack;

  /// No description provided for @templatesToSubmitYourCreationExport.
  ///
  /// In en, this message translates to:
  /// **'To submit your creation: export the JSON, open GitHub, add the file and open a pull request. Publication follows a review. A GitHub account is needed to contribute to the catalogue.'**
  String get templatesToSubmitYourCreationExport;

  /// No description provided for @templatesScoring.
  ///
  /// In en, this message translates to:
  /// **'Scoring'**
  String get templatesScoring;

  /// No description provided for @templatesRulesAndVariants.
  ///
  /// In en, this message translates to:
  /// **'Rules and variants'**
  String get templatesRulesAndVariants;

  /// No description provided for @templatesOpenTheReferenceRules.
  ///
  /// In en, this message translates to:
  /// **'Open the reference rules'**
  String get templatesOpenTheReferenceRules;

  /// No description provided for @templatesNoNotesYetYouCan.
  ///
  /// In en, this message translates to:
  /// **'No notes yet. You can write your variants in the builder.'**
  String get templatesNoNotesYetYouCan;

  /// No description provided for @templatesPlayWithThisPack.
  ///
  /// In en, this message translates to:
  /// **'Play with this pack'**
  String get templatesPlayWithThisPack;

  /// No description provided for @templatesCreateACharacter.
  ///
  /// In en, this message translates to:
  /// **'Create a character'**
  String get templatesCreateACharacter;

  /// No description provided for @templatesCustomise.
  ///
  /// In en, this message translates to:
  /// **'Customise'**
  String get templatesCustomise;

  /// No description provided for @templatesAllToolsInFreeMode.
  ///
  /// In en, this message translates to:
  /// **'All tools in free mode'**
  String get templatesAllToolsInFreeMode;

  /// No description provided for @templatesExportThePackJson.
  ///
  /// In en, this message translates to:
  /// **'Export the pack JSON'**
  String get templatesExportThePackJson;

  /// No description provided for @templatesSubmitToTheGallery.
  ///
  /// In en, this message translates to:
  /// **'Submit to the gallery'**
  String get templatesSubmitToTheGallery;

  /// No description provided for @templatesPickOnlyTheToolsThis.
  ///
  /// In en, this message translates to:
  /// **'Pick only the tools this game needs. The next steps adapt to your choice.'**
  String get templatesPickOnlyTheToolsThis;

  /// No description provided for @templatesPlayerCountersAndStatuses.
  ///
  /// In en, this message translates to:
  /// **'Player counters and statuses'**
  String get templatesPlayerCountersAndStatuses;

  /// No description provided for @templatesLivesEnergyPoisonShield.
  ///
  /// In en, this message translates to:
  /// **'Lives, energy, poison, shield…'**
  String get templatesLivesEnergyPoisonShield;

  /// No description provided for @templatesQuantityPoints.
  ///
  /// In en, this message translates to:
  /// **'Quantity × points'**
  String get templatesQuantityPoints;

  /// No description provided for @templatesCompleteSets.
  ///
  /// In en, this message translates to:
  /// **'Complete sets'**
  String get templatesCompleteSets;

  /// No description provided for @templatesProgression123.
  ///
  /// In en, this message translates to:
  /// **'Progression 1 + 2 + 3…'**
  String get templatesProgression123;

  /// No description provided for @templatesBonusFromAThreshold.
  ///
  /// In en, this message translates to:
  /// **'Bonus from a threshold'**
  String get templatesBonusFromAThreshold;

  /// No description provided for @templatesCustomTable.
  ///
  /// In en, this message translates to:
  /// **'Custom table'**
  String get templatesCustomTable;

  /// No description provided for @templates03Scoring.
  ///
  /// In en, this message translates to:
  /// **'03 / Scoring'**
  String get templates03Scoring;

  /// No description provided for @templatesEachCategoryComputesATotal.
  ///
  /// In en, this message translates to:
  /// **'Each category computes a total from a quantity. The score sheet replaces the category total; it does not add it twice.'**
  String get templatesEachCategoryComputesATotal;

  /// No description provided for @templatesAddACategory.
  ///
  /// In en, this message translates to:
  /// **'Add a category'**
  String get templatesAddACategory;

  /// No description provided for @templatesPointsGoal0None.
  ///
  /// In en, this message translates to:
  /// **'Points goal (0 = none)'**
  String get templatesPointsGoal0None;

  /// No description provided for @templatesLowestScoreWins.
  ///
  /// In en, this message translates to:
  /// **'Lowest score wins'**
  String get templatesLowestScoreWins;

  /// No description provided for @templatesCooperativeGoal.
  ///
  /// In en, this message translates to:
  /// **'Cooperative goal'**
  String get templatesCooperativeGoal;

  /// No description provided for @templatesPointsCategory.
  ///
  /// In en, this message translates to:
  /// **'Points category'**
  String get templatesPointsCategory;

  /// No description provided for @templatesCalculationMethod.
  ///
  /// In en, this message translates to:
  /// **'Calculation method'**
  String get templatesCalculationMethod;

  /// No description provided for @templatesPointsWhenTheThresholdIs.
  ///
  /// In en, this message translates to:
  /// **'Points when the threshold is reached'**
  String get templatesPointsWhenTheThresholdIs;

  /// No description provided for @templatesPointsPerUnitOrSet.
  ///
  /// In en, this message translates to:
  /// **'Points per unit or set'**
  String get templatesPointsPerUnitOrSet;

  /// No description provided for @templatesSetSize.
  ///
  /// In en, this message translates to:
  /// **'Set size'**
  String get templatesSetSize;

  /// No description provided for @templatesThresholdToReach.
  ///
  /// In en, this message translates to:
  /// **'Threshold to reach'**
  String get templatesThresholdToReach;

  /// No description provided for @templatesTableFor012.
  ///
  /// In en, this message translates to:
  /// **'Table for 0, 1, 2, 3…'**
  String get templatesTableFor012;

  /// No description provided for @templatesCommaSeparatedValues01.
  ///
  /// In en, this message translates to:
  /// **'Comma-separated values: 0, 1, 3, 6, 10'**
  String get templatesCommaSeparatedValues01;

  /// No description provided for @templatesFixedBonusOrPenalty.
  ///
  /// In en, this message translates to:
  /// **'Fixed bonus or penalty'**
  String get templatesFixedBonusOrPenalty;

  /// No description provided for @templatesRemoveThisCategory.
  ///
  /// In en, this message translates to:
  /// **'Remove this category'**
  String get templatesRemoveThisCategory;

  /// No description provided for @templates05RulesAndReferences.
  ///
  /// In en, this message translates to:
  /// **'05 / Rules and references'**
  String get templates05RulesAndReferences;

  /// No description provided for @templatesHttpsLinkToTheRules.
  ///
  /// In en, this message translates to:
  /// **'HTTPS link to the rules or the publisher site'**
  String get templatesHttpsLinkToTheRules;

  /// No description provided for @templatesTheLinkOpensInThe.
  ///
  /// In en, this message translates to:
  /// **'The link opens in the browser. The remote booklet is not downloaded.'**
  String get templatesTheLinkOpensInThe;

  /// No description provided for @templatesYourNotesAndVariants.
  ///
  /// In en, this message translates to:
  /// **'Your notes and variants'**
  String get templatesYourNotesAndVariants;

  /// No description provided for @templatesTheseNotesWillBeAvailable.
  ///
  /// In en, this message translates to:
  /// **'These notes will be available offline in the pack.'**
  String get templatesTheseNotesWillBeAvailable;

  /// No description provided for @templatesChosenTools.
  ///
  /// In en, this message translates to:
  /// **'Chosen tools'**
  String get templatesChosenTools;

  /// No description provided for @templatesPublishingAndCredits.
  ///
  /// In en, this message translates to:
  /// **'Publishing and credits'**
  String get templatesPublishingAndCredits;

  /// No description provided for @templatesPackAuthor.
  ///
  /// In en, this message translates to:
  /// **'Pack author'**
  String get templatesPackAuthor;

  /// No description provided for @templatesPackLicence.
  ///
  /// In en, this message translates to:
  /// **'Pack licence'**
  String get templatesPackLicence;

  /// No description provided for @templatesMitCc010Cc.
  ///
  /// In en, this message translates to:
  /// **'MIT, CC0-1.0, CC-BY-4.0… The content must be yours or allowed.'**
  String get templatesMitCc010Cc;

  /// No description provided for @templatesPackVersion.
  ///
  /// In en, this message translates to:
  /// **'Pack version'**
  String get templatesPackVersion;

  /// No description provided for @templatesTemplateImported.
  ///
  /// In en, this message translates to:
  /// **'Template imported'**
  String get templatesTemplateImported;

  /// No description provided for @templatesYourRulesYourGames.
  ///
  /// In en, this message translates to:
  /// **'Your rules / your games'**
  String get templatesYourRulesYourGames;

  /// No description provided for @templatesYourGameCompanions.
  ///
  /// In en, this message translates to:
  /// **'Your game companions'**
  String get templatesYourGameCompanions;

  /// No description provided for @templatesTheseTemplatesConfigureScoresTargets.
  ///
  /// In en, this message translates to:
  /// **'These templates configure scores, targets and timers.'**
  String get templatesTheseTemplatesConfigureScoresTargets;

  /// No description provided for @templatesCreateCompanion.
  ///
  /// In en, this message translates to:
  /// **'Create companion'**
  String get templatesCreateCompanion;

  /// No description provided for @templatesImportJsonTemplate.
  ///
  /// In en, this message translates to:
  /// **'Import JSON template'**
  String get templatesImportJsonTemplate;

  /// No description provided for @templatesTarget.
  ///
  /// In en, this message translates to:
  /// **'Target {target}'**
  String templatesTarget(Object target);

  /// No description provided for @templatesUseTemplate.
  ///
  /// In en, this message translates to:
  /// **'Use template'**
  String get templatesUseTemplate;

  /// No description provided for @templatesDeleteTemplate.
  ///
  /// In en, this message translates to:
  /// **'Delete template?'**
  String get templatesDeleteTemplate;

  /// No description provided for @templatesEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get templatesEdit;

  /// No description provided for @templatesCopyToMyWorkshop.
  ///
  /// In en, this message translates to:
  /// **'Copy to my workshop'**
  String get templatesCopyToMyWorkshop;

  /// No description provided for @templatesPackToolsAndRules.
  ///
  /// In en, this message translates to:
  /// **'Pack tools and rules'**
  String get templatesPackToolsAndRules;

  /// No description provided for @templatesShareByQr.
  ///
  /// In en, this message translates to:
  /// **'Share by QR'**
  String get templatesShareByQr;

  /// No description provided for @gameGameToolsAndRules.
  ///
  /// In en, this message translates to:
  /// **'Game tools and rules'**
  String get gameGameToolsAndRules;

  /// No description provided for @gameUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get gameUndo;

  /// No description provided for @gameRedo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get gameRedo;

  /// No description provided for @gameNextPlayer.
  ///
  /// In en, this message translates to:
  /// **'Next player'**
  String get gameNextPlayer;

  /// No description provided for @gameGameLog.
  ///
  /// In en, this message translates to:
  /// **'Game log'**
  String get gameGameLog;

  /// No description provided for @gameReadyForYourFirstMove.
  ///
  /// In en, this message translates to:
  /// **'Ready for your first move.'**
  String get gameReadyForYourFirstMove;

  /// No description provided for @gameGameNotes.
  ///
  /// In en, this message translates to:
  /// **'Game notes'**
  String get gameGameNotes;

  /// No description provided for @gameNotesGoals.
  ///
  /// In en, this message translates to:
  /// **'Notes & goals'**
  String get gameNotesGoals;

  /// No description provided for @gameEditNotes.
  ///
  /// In en, this message translates to:
  /// **'Edit notes'**
  String get gameEditNotes;

  /// No description provided for @gameYourStrategyObjectivesAndNotes.
  ///
  /// In en, this message translates to:
  /// **'Your strategy, objectives and notes.'**
  String get gameYourStrategyObjectivesAndNotes;

  /// No description provided for @gameCooperative.
  ///
  /// In en, this message translates to:
  /// **'Cooperative'**
  String get gameCooperative;

  /// No description provided for @gameLowestScoreWins.
  ///
  /// In en, this message translates to:
  /// **'Lowest score wins'**
  String get gameLowestScoreWins;

  /// No description provided for @gameHighestScoreWins.
  ///
  /// In en, this message translates to:
  /// **'Highest score wins'**
  String get gameHighestScoreWins;

  /// No description provided for @gamePlayers.
  ///
  /// In en, this message translates to:
  /// **'players'**
  String get gamePlayers;

  /// No description provided for @gameRound.
  ///
  /// In en, this message translates to:
  /// **'Round'**
  String get gameRound;

  /// No description provided for @gameActiveGameLocalData.
  ///
  /// In en, this message translates to:
  /// **'Active game / local data'**
  String get gameActiveGameLocalData;

  /// No description provided for @gameCompletedGame.
  ///
  /// In en, this message translates to:
  /// **'Completed game'**
  String get gameCompletedGame;

  /// No description provided for @gamePlayAgain.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get gamePlayAgain;

  /// No description provided for @gameYourTableAwaits.
  ///
  /// In en, this message translates to:
  /// **'Your table awaits'**
  String get gameYourTableAwaits;

  /// No description provided for @gameCreateAGameToTrack.
  ///
  /// In en, this message translates to:
  /// **'Create a game to track scores and turns.'**
  String get gameCreateAGameToTrack;

  /// No description provided for @gameCreateGame.
  ///
  /// In en, this message translates to:
  /// **'Create game'**
  String get gameCreateGame;

  /// No description provided for @gameTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get gameTarget;

  /// No description provided for @gameFinishGame.
  ///
  /// In en, this message translates to:
  /// **'Finish game?'**
  String get gameFinishGame;

  /// No description provided for @gameScoresWillBeKeptIn.
  ///
  /// In en, this message translates to:
  /// **'Scores will be kept in your history.'**
  String get gameScoresWillBeKeptIn;

  /// No description provided for @gameNextRound.
  ///
  /// In en, this message translates to:
  /// **'Next round'**
  String get gameNextRound;

  /// No description provided for @gameMoreActions.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get gameMoreActions;

  /// No description provided for @gameTurnDirection.
  ///
  /// In en, this message translates to:
  /// **'Turn direction'**
  String get gameTurnDirection;

  /// No description provided for @gameFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get gameFinish;

  /// No description provided for @gameActivePlayer.
  ///
  /// In en, this message translates to:
  /// **'Active player'**
  String get gameActivePlayer;

  /// No description provided for @gamePointsFor.
  ///
  /// In en, this message translates to:
  /// **'Points for'**
  String get gamePointsFor;

  /// No description provided for @gamePositiveOrNegativeValue.
  ///
  /// In en, this message translates to:
  /// **'Positive or negative value'**
  String get gamePositiveOrNegativeValue;

  /// No description provided for @gameInvalidValue.
  ///
  /// In en, this message translates to:
  /// **'Invalid value'**
  String get gameInvalidValue;

  /// No description provided for @gameCustomValue.
  ///
  /// In en, this message translates to:
  /// **'Custom value'**
  String get gameCustomValue;

  /// No description provided for @gameLives.
  ///
  /// In en, this message translates to:
  /// **'Lives'**
  String get gameLives;

  /// No description provided for @gameCounter.
  ///
  /// In en, this message translates to:
  /// **'Counter'**
  String get gameCounter;

  /// No description provided for @gameRemove1From.
  ///
  /// In en, this message translates to:
  /// **'Remove 1 from'**
  String get gameRemove1From;

  /// No description provided for @gameAdd1To.
  ///
  /// In en, this message translates to:
  /// **'Add 1 to'**
  String get gameAdd1To;

  /// No description provided for @gameStackSTapToAdd.
  ///
  /// In en, this message translates to:
  /// **'{status}: {stacks} stack(s), tap to add one'**
  String gameStackSTapToAdd(Object status, Object stacks);

  /// No description provided for @gameRemoveOneStack.
  ///
  /// In en, this message translates to:
  /// **'Remove one {status} stack'**
  String gameRemoveOneStack(Object status);

  /// No description provided for @gameCreateAGameToUse.
  ///
  /// In en, this message translates to:
  /// **'Create a game to use this sheet.'**
  String get gameCreateAGameToUse;

  /// No description provided for @gameApplyThisScoring.
  ///
  /// In en, this message translates to:
  /// **'Apply this scoring'**
  String get gameApplyThisScoring;

  /// No description provided for @gameEnterAtLeastOneQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter at least one quantity.'**
  String get gameEnterAtLeastOneQuantity;

  /// No description provided for @gameEnterValidNumbers.
  ///
  /// In en, this message translates to:
  /// **'Enter valid numbers.'**
  String get gameEnterValidNumbers;

  /// No description provided for @gameCurrentTotal.
  ///
  /// In en, this message translates to:
  /// **'Current total'**
  String get gameCurrentTotal;

  /// No description provided for @gameResult.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get gameResult;

  /// No description provided for @gameEnterTheFinalQuantitiesFilled.
  ///
  /// In en, this message translates to:
  /// **'Enter the final quantities. Filled categories replace their total for this round. Empty fields stay unchanged.'**
  String get gameEnterTheFinalQuantitiesFilled;

  /// No description provided for @gameThisTemplateUsesFreeScores.
  ///
  /// In en, this message translates to:
  /// **'This template uses free scores. Add scoring rules in the builder, then start a game with this pack.'**
  String get gameThisTemplateUsesFreeScores;

  /// No description provided for @accountSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get accountSignIn;

  /// No description provided for @accountSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get accountSignUp;

  /// No description provided for @accountName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get accountName;

  /// No description provided for @accountEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get accountEmail;

  /// No description provided for @accountPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get accountPassword;

  /// No description provided for @accountAtLeast8Characters.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get accountAtLeast8Characters;

  /// No description provided for @accountCreateMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Create my account'**
  String get accountCreateMyAccount;

  /// No description provided for @accountSignIn2.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get accountSignIn2;

  /// No description provided for @accountForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get accountForgotPassword;

  /// No description provided for @accountNameSaved.
  ///
  /// In en, this message translates to:
  /// **'Name saved'**
  String get accountNameSaved;

  /// No description provided for @accountAccountCreatedConfirmWithThe.
  ///
  /// In en, this message translates to:
  /// **'Account created: confirm with the email you received.'**
  String get accountAccountCreatedConfirmWithThe;

  /// No description provided for @accountSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get accountSignedIn;

  /// No description provided for @accountSignedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed out'**
  String get accountSignedOut;

  /// No description provided for @accountResetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Reset email sent.'**
  String get accountResetEmailSent;

  /// No description provided for @accountSignInLinkSentCheck.
  ///
  /// In en, this message translates to:
  /// **'Sign-in link sent: check your email.'**
  String get accountSignInLinkSentCheck;

  /// No description provided for @accountPasswordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get accountPasswordChanged;

  /// No description provided for @accountOnlineAccount.
  ///
  /// In en, this message translates to:
  /// **'Online account'**
  String get accountOnlineAccount;

  /// No description provided for @accountLocalMode.
  ///
  /// In en, this message translates to:
  /// **'Local mode'**
  String get accountLocalMode;

  /// No description provided for @accountThisBuildHasNoServer.
  ///
  /// In en, this message translates to:
  /// **'This build has no server: everything stays on the device. Wi-Fi lobbies work without an account.'**
  String get accountThisBuildHasNoServer;

  /// No description provided for @accountTheNameFriendsSeeWhen.
  ///
  /// In en, this message translates to:
  /// **'The name friends see when you join a game.'**
  String get accountTheNameFriendsSeeWhen;

  /// No description provided for @accountYourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get accountYourName;

  /// No description provided for @accountInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get accountInvalidEmail;

  /// No description provided for @accountPasswordAtLeast8Characters.
  ///
  /// In en, this message translates to:
  /// **'Password: at least 8 characters'**
  String get accountPasswordAtLeast8Characters;

  /// No description provided for @accountInvalidName.
  ///
  /// In en, this message translates to:
  /// **'Invalid name'**
  String get accountInvalidName;

  /// No description provided for @accountInvalidCodeTypeTheDigits.
  ///
  /// In en, this message translates to:
  /// **'Invalid code: type the digits from the email.'**
  String get accountInvalidCodeTypeTheDigits;

  /// No description provided for @accountSignInFirst.
  ///
  /// In en, this message translates to:
  /// **'Sign in first'**
  String get accountSignInFirst;

  /// No description provided for @accountTheServerRefusedCheckThe.
  ///
  /// In en, this message translates to:
  /// **'The server refused: check the email and password.'**
  String get accountTheServerRefusedCheckThe;

  /// No description provided for @accountNoServerConfigured.
  ///
  /// In en, this message translates to:
  /// **'No server configured'**
  String get accountNoServerConfigured;

  /// No description provided for @accountCouldNotConnect.
  ///
  /// In en, this message translates to:
  /// **'Could not connect'**
  String get accountCouldNotConnect;

  /// No description provided for @accountEmailMeASignIn.
  ///
  /// In en, this message translates to:
  /// **'Email me a sign-in link'**
  String get accountEmailMeASignIn;

  /// No description provided for @accountOpenTheLinkOnThis.
  ///
  /// In en, this message translates to:
  /// **'Open the link on this device, or type the code from the email.'**
  String get accountOpenTheLinkOnThis;

  /// No description provided for @accountCodeReceived.
  ///
  /// In en, this message translates to:
  /// **'Code received'**
  String get accountCodeReceived;

  /// No description provided for @accountConfirmTheCode.
  ///
  /// In en, this message translates to:
  /// **'Confirm the code'**
  String get accountConfirmTheCode;

  /// No description provided for @accountAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get accountAdmin;

  /// No description provided for @accountNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get accountNewPassword;

  /// No description provided for @accountOptionalTheEmailLinkIs.
  ///
  /// In en, this message translates to:
  /// **'Optional: the email link is enough to sign in.'**
  String get accountOptionalTheEmailLinkIs;

  /// No description provided for @accountChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get accountChangePassword;

  /// No description provided for @accountManageAccounts.
  ///
  /// In en, this message translates to:
  /// **'Manage accounts'**
  String get accountManageAccounts;

  /// No description provided for @accountSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get accountSignOut;

  /// No description provided for @adminListUnavailable.
  ///
  /// In en, this message translates to:
  /// **'List unavailable'**
  String get adminListUnavailable;

  /// No description provided for @adminAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get adminAccounts;

  /// No description provided for @adminInviteSomeone.
  ///
  /// In en, this message translates to:
  /// **'Invite someone'**
  String get adminInviteSomeone;

  /// No description provided for @adminAccounts2.
  ///
  /// In en, this message translates to:
  /// **'{count} accounts'**
  String adminAccounts2(Object count);

  /// No description provided for @adminAdminsOnlySignInAgain.
  ///
  /// In en, this message translates to:
  /// **'Admins only: sign in again if you just got the role.'**
  String get adminAdminsOnlySignInAgain;

  /// No description provided for @adminNotPossibleOnYourOwn.
  ///
  /// In en, this message translates to:
  /// **'Not possible on your own account.'**
  String get adminNotPossibleOnYourOwn;

  /// No description provided for @adminTheServerRefusedTheOperation.
  ///
  /// In en, this message translates to:
  /// **'The server refused the operation.'**
  String get adminTheServerRefusedTheOperation;

  /// No description provided for @adminInvitationSent.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent'**
  String get adminInvitationSent;

  /// No description provided for @adminAccountUpdated.
  ///
  /// In en, this message translates to:
  /// **'Account updated'**
  String get adminAccountUpdated;

  /// No description provided for @adminAccountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get adminAccountDeleted;

  /// No description provided for @adminNeverSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Never signed in'**
  String get adminNeverSignedIn;

  /// No description provided for @adminLastSignIn.
  ///
  /// In en, this message translates to:
  /// **'Last sign-in: {value}'**
  String adminLastSignIn(Object value);

  /// No description provided for @adminTheyGetAnEmailTo.
  ///
  /// In en, this message translates to:
  /// **'They get an email to activate their account.'**
  String get adminTheyGetAnEmailTo;

  /// No description provided for @adminNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get adminNameOptional;

  /// No description provided for @adminInvite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get adminInvite;

  /// No description provided for @adminDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete {label}?'**
  String adminDelete(Object label);

  /// No description provided for @adminTheAccountAndItsPublished.
  ///
  /// In en, this message translates to:
  /// **'The account and its published nights will be deleted. This cannot be undone.'**
  String get adminTheAccountAndItsPublished;

  /// No description provided for @adminBlocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get adminBlocked;

  /// No description provided for @adminPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get adminPending;

  /// No description provided for @adminAccountActions.
  ///
  /// In en, this message translates to:
  /// **'Account actions'**
  String get adminAccountActions;

  /// No description provided for @adminRemoveAdminRole.
  ///
  /// In en, this message translates to:
  /// **'Remove admin role'**
  String get adminRemoveAdminRole;

  /// No description provided for @adminMakeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Make admin'**
  String get adminMakeAdmin;

  /// No description provided for @adminUnblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get adminUnblock;

  /// No description provided for @adminBlock.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get adminBlock;

  /// No description provided for @eveningsRemoveThisNight.
  ///
  /// In en, this message translates to:
  /// **'Remove this night?'**
  String get eveningsRemoveThisNight;

  /// No description provided for @eveningsSignUpsWillBeLost.
  ///
  /// In en, this message translates to:
  /// **'Sign-ups will be lost.'**
  String get eveningsSignUpsWillBeLost;

  /// No description provided for @eveningsItLeavesYourList.
  ///
  /// In en, this message translates to:
  /// **'It leaves your list.'**
  String get eveningsItLeavesYourList;

  /// No description provided for @eveningsGameNight.
  ///
  /// In en, this message translates to:
  /// **'Game night'**
  String get eveningsGameNight;

  /// No description provided for @eveningsRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get eveningsRefresh;

  /// No description provided for @eveningsRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get eveningsRemove;

  /// No description provided for @eveningsNightNotFound.
  ///
  /// In en, this message translates to:
  /// **'Night not found'**
  String get eveningsNightNotFound;

  /// No description provided for @eveningsItWasRemoved.
  ///
  /// In en, this message translates to:
  /// **'It was removed.'**
  String get eveningsItWasRemoved;

  /// No description provided for @eveningsOnTheMenu.
  ///
  /// In en, this message translates to:
  /// **'On the menu: {value}'**
  String eveningsOnTheMenu(Object value);

  /// No description provided for @eveningsYourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get eveningsYourAnswer;

  /// No description provided for @eveningsSignInToSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sign up'**
  String get eveningsSignInToSignUp;

  /// No description provided for @eveningsFullYouAreOnThe.
  ///
  /// In en, this message translates to:
  /// **'Full: you are on the waiting list.'**
  String get eveningsFullYouAreOnThe;

  /// No description provided for @eveningsTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get eveningsTitle;

  /// No description provided for @eveningsGamesAtLAS.
  ///
  /// In en, this message translates to:
  /// **'Games at Léa’s'**
  String get eveningsGamesAtLAS;

  /// No description provided for @eveningsPlace.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get eveningsPlace;

  /// No description provided for @eveningsChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get eveningsChange;

  /// No description provided for @eveningsSeatsNoLimit.
  ///
  /// In en, this message translates to:
  /// **'Seats: no limit'**
  String get eveningsSeatsNoLimit;

  /// No description provided for @eveningsSeatsYouIncluded.
  ///
  /// In en, this message translates to:
  /// **'Seats: {seats} (you included)'**
  String eveningsSeatsYouIncluded(Object seats);

  /// No description provided for @eveningsPlannedGames.
  ///
  /// In en, this message translates to:
  /// **'Planned games'**
  String get eveningsPlannedGames;

  /// No description provided for @eveningsWithoutAServerRecordYour.
  ///
  /// In en, this message translates to:
  /// **'Without a server, record your friends’ answers yourself below.'**
  String get eveningsWithoutAServerRecordYour;

  /// No description provided for @eveningsInviteOnline.
  ///
  /// In en, this message translates to:
  /// **'Invite online'**
  String get eveningsInviteOnline;

  /// No description provided for @eveningsPublishTheNightFriendsSign.
  ///
  /// In en, this message translates to:
  /// **'Publish the night: friends sign up with the link, code or QR.'**
  String get eveningsPublishTheNightFriendsSign;

  /// No description provided for @eveningsPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get eveningsPublish;

  /// No description provided for @eveningsSignInToPublish.
  ///
  /// In en, this message translates to:
  /// **'Sign in to publish'**
  String get eveningsSignInToPublish;

  /// No description provided for @eveningsFriendsAnswers.
  ///
  /// In en, this message translates to:
  /// **'Friends’ answers'**
  String get eveningsFriendsAnswers;

  /// No description provided for @eveningsNoAnswer.
  ///
  /// In en, this message translates to:
  /// **'No answer'**
  String get eveningsNoAnswer;

  /// No description provided for @eveningsSAnswer.
  ///
  /// In en, this message translates to:
  /// **'{name}’s answer'**
  String eveningsSAnswer(Object name);

  /// No description provided for @eveningsInvitation.
  ///
  /// In en, this message translates to:
  /// **'Invitation'**
  String get eveningsInvitation;

  /// No description provided for @eveningsCheckTheCodeWithThe.
  ///
  /// In en, this message translates to:
  /// **'Check the code with the host.'**
  String get eveningsCheckTheCodeWithThe;

  /// No description provided for @eveningsThisBuildHasNoServer.
  ///
  /// In en, this message translates to:
  /// **'This build has no server to look up nights.'**
  String get eveningsThisBuildHasNoServer;

  /// No description provided for @eveningsGoing.
  ///
  /// In en, this message translates to:
  /// **'Going'**
  String get eveningsGoing;

  /// No description provided for @eveningsWaitingList.
  ///
  /// In en, this message translates to:
  /// **'Waiting list'**
  String get eveningsWaitingList;

  /// No description provided for @eveningsMaybe.
  ///
  /// In en, this message translates to:
  /// **'Maybe'**
  String get eveningsMaybe;

  /// No description provided for @eveningsNotComing.
  ///
  /// In en, this message translates to:
  /// **'Not coming'**
  String get eveningsNotComing;

  /// No description provided for @eveningsHosting.
  ///
  /// In en, this message translates to:
  /// **'Hosting'**
  String get eveningsHosting;

  /// No description provided for @eveningsIMIn.
  ///
  /// In en, this message translates to:
  /// **'I’m in'**
  String get eveningsIMIn;

  /// No description provided for @eveningsNotThisTime.
  ///
  /// In en, this message translates to:
  /// **'Not this time'**
  String get eveningsNotThisTime;

  /// No description provided for @eveningsGoing2.
  ///
  /// In en, this message translates to:
  /// **'{going} going'**
  String eveningsGoing2(Object going);

  /// No description provided for @eveningsSeats.
  ///
  /// In en, this message translates to:
  /// **'{going}/{seats} seats'**
  String eveningsSeats(Object going, Object seats);

  /// No description provided for @eveningsWaiting.
  ///
  /// In en, this message translates to:
  /// **'{base} · {waiting} waiting'**
  String eveningsWaiting(Object base, Object waiting);

  /// No description provided for @eveningsHostOnly.
  ///
  /// In en, this message translates to:
  /// **'Host only'**
  String get eveningsHostOnly;

  /// No description provided for @eveningsCouldNotDoItCheck.
  ///
  /// In en, this message translates to:
  /// **'Could not do it: check the connection and your account.'**
  String get eveningsCouldNotDoItCheck;

  /// No description provided for @eveningsPlanANight.
  ///
  /// In en, this message translates to:
  /// **'Plan a night'**
  String get eveningsPlanANight;

  /// No description provided for @eveningsIHaveACode.
  ///
  /// In en, this message translates to:
  /// **'I have a code'**
  String get eveningsIHaveACode;

  /// No description provided for @eveningsUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get eveningsUpcoming;

  /// No description provided for @eveningsNoNightPlanned.
  ///
  /// In en, this message translates to:
  /// **'No night planned'**
  String get eveningsNoNightPlanned;

  /// No description provided for @eveningsPickADateInviteBy.
  ///
  /// In en, this message translates to:
  /// **'Pick a date, invite by link or QR, and everyone signs up.'**
  String get eveningsPickADateInviteBy;

  /// No description provided for @eveningsPast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get eveningsPast;

  /// No description provided for @friendsThisFriendAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This friend already exists.'**
  String get friendsThisFriendAlreadyExists;

  /// No description provided for @friendsRemoveThisFriend.
  ///
  /// In en, this message translates to:
  /// **'Remove this friend?'**
  String get friendsRemoveThisFriend;

  /// No description provided for @friendsFriendProfile.
  ///
  /// In en, this message translates to:
  /// **'Friend profile'**
  String get friendsFriendProfile;

  /// No description provided for @friendsNameOrNickname.
  ///
  /// In en, this message translates to:
  /// **'Name or nickname'**
  String get friendsNameOrNickname;

  /// No description provided for @friendsTastes.
  ///
  /// In en, this message translates to:
  /// **'Tastes'**
  String get friendsTastes;

  /// No description provided for @friendsTapAGenreLikesThen.
  ///
  /// In en, this message translates to:
  /// **'Tap a genre: likes, then dislikes, then neutral.'**
  String get friendsTapAGenreLikesThen;

  /// No description provided for @friendsLongestGame.
  ///
  /// In en, this message translates to:
  /// **'Longest game'**
  String get friendsLongestGame;

  /// No description provided for @friendsNoLimit.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get friendsNoLimit;

  /// No description provided for @friendsPerGameOpinion.
  ///
  /// In en, this message translates to:
  /// **'Per-game opinion'**
  String get friendsPerGameOpinion;

  /// No description provided for @friendsTapAGameWantsIt.
  ///
  /// In en, this message translates to:
  /// **'Tap a game: wants it, loves it despite the genre, refuses it, neutral.'**
  String get friendsTapAGameWantsIt;

  /// No description provided for @friendsLikes.
  ///
  /// In en, this message translates to:
  /// **'likes'**
  String get friendsLikes;

  /// No description provided for @friendsDislikes.
  ///
  /// In en, this message translates to:
  /// **'dislikes'**
  String get friendsDislikes;

  /// No description provided for @friendsNeutral.
  ///
  /// In en, this message translates to:
  /// **'neutral'**
  String get friendsNeutral;

  /// No description provided for @friendsWants.
  ///
  /// In en, this message translates to:
  /// **'wants'**
  String get friendsWants;

  /// No description provided for @friendsLoves.
  ///
  /// In en, this message translates to:
  /// **'loves'**
  String get friendsLoves;

  /// No description provided for @friendsRefused.
  ///
  /// In en, this message translates to:
  /// **'refused'**
  String get friendsRefused;

  /// No description provided for @friendsYourShelfIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your shelf is empty.'**
  String get friendsYourShelfIsEmpty;

  /// No description provided for @friendsAroundTheTable.
  ///
  /// In en, this message translates to:
  /// **'Around the table'**
  String get friendsAroundTheTable;

  /// No description provided for @friendsMyFriends.
  ///
  /// In en, this message translates to:
  /// **'My friends'**
  String get friendsMyFriends;

  /// No description provided for @friendsTheirTastesAndReviewsTo.
  ///
  /// In en, this message translates to:
  /// **'Their tastes and reviews, to pick the right game.'**
  String get friendsTheirTastesAndReviewsTo;

  /// No description provided for @friendsAddAFriend.
  ///
  /// In en, this message translates to:
  /// **'Add a friend'**
  String get friendsAddAFriend;

  /// No description provided for @friendsNobodyYet.
  ///
  /// In en, this message translates to:
  /// **'Nobody yet'**
  String get friendsNobodyYet;

  /// No description provided for @friendsAddYourGamePartnersAnd.
  ///
  /// In en, this message translates to:
  /// **'Add your game partners and what they like.'**
  String get friendsAddYourGamePartnersAnd;

  /// No description provided for @friendsLatestReviews.
  ///
  /// In en, this message translates to:
  /// **'Latest reviews'**
  String get friendsLatestReviews;

  /// No description provided for @friendsLikes2.
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get friendsLikes2;

  /// No description provided for @friendsDislikes2.
  ///
  /// In en, this message translates to:
  /// **'Dislikes'**
  String get friendsDislikes2;

  /// No description provided for @friendsGamesUpTo.
  ///
  /// In en, this message translates to:
  /// **'Games up to'**
  String get friendsGamesUpTo;

  /// No description provided for @friendsStarsOutOf5.
  ///
  /// In en, this message translates to:
  /// **'{stars} stars out of 5'**
  String friendsStarsOutOf5(Object stars);

  /// No description provided for @friendsReviewsSaved.
  ///
  /// In en, this message translates to:
  /// **'Reviews saved'**
  String get friendsReviewsSaved;

  /// No description provided for @friendsRateTheGame.
  ///
  /// In en, this message translates to:
  /// **'Rate the game'**
  String get friendsRateTheGame;

  /// No description provided for @friendsGameNotFound.
  ///
  /// In en, this message translates to:
  /// **'Game not found'**
  String get friendsGameNotFound;

  /// No description provided for @friendsItMayHaveBeenDeleted.
  ///
  /// In en, this message translates to:
  /// **'It may have been deleted.'**
  String get friendsItMayHaveBeenDeleted;

  /// No description provided for @friendsSaveReviews.
  ///
  /// In en, this message translates to:
  /// **'Save reviews'**
  String get friendsSaveReviews;

  /// No description provided for @friendsStarSOf5.
  ///
  /// In en, this message translates to:
  /// **'{i} star(s) of 5'**
  String friendsStarSOf5(Object i);

  /// No description provided for @friendsAWordOnTheGame.
  ///
  /// In en, this message translates to:
  /// **'A word on the game'**
  String get friendsAWordOnTheGame;

  /// No description provided for @historyTeam.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get historyTeam;

  /// No description provided for @historyLeading.
  ///
  /// In en, this message translates to:
  /// **'Leading'**
  String get historyLeading;

  /// No description provided for @historyWinner.
  ///
  /// In en, this message translates to:
  /// **'Winner'**
  String get historyWinner;

  /// No description provided for @historyActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get historyActive;

  /// No description provided for @historyComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get historyComplete;

  /// No description provided for @historyRounds.
  ///
  /// In en, this message translates to:
  /// **'rounds'**
  String get historyRounds;

  /// No description provided for @historyDeleteThisGame.
  ///
  /// In en, this message translates to:
  /// **'Delete this game?'**
  String get historyDeleteThisGame;

  /// No description provided for @historyThisAlsoRemovesScoresAnd.
  ///
  /// In en, this message translates to:
  /// **'This also removes scores and notes.'**
  String get historyThisAlsoRemovesScoresAnd;

  /// No description provided for @historyResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get historyResume;

  /// No description provided for @historyDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get historyDetails;

  /// No description provided for @historyPlayAgain.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get historyPlayAgain;

  /// No description provided for @historyRate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get historyRate;

  /// No description provided for @historyMemories.
  ///
  /// In en, this message translates to:
  /// **'Memories'**
  String get historyMemories;

  /// No description provided for @historyDeleteGame.
  ///
  /// In en, this message translates to:
  /// **'Delete game'**
  String get historyDeleteGame;

  /// No description provided for @historyGameImported.
  ///
  /// In en, this message translates to:
  /// **'Game imported'**
  String get historyGameImported;

  /// No description provided for @historyKeepTheGoodTimes.
  ///
  /// In en, this message translates to:
  /// **'Keep the good times'**
  String get historyKeepTheGoodTimes;

  /// No description provided for @historyTheGoodTimes.
  ///
  /// In en, this message translates to:
  /// **'The good times'**
  String get historyTheGoodTimes;

  /// No description provided for @historyYourGamesAndResultsSaved.
  ///
  /// In en, this message translates to:
  /// **'Your games and results, saved on this device.'**
  String get historyYourGamesAndResultsSaved;

  /// No description provided for @historyImportGame.
  ///
  /// In en, this message translates to:
  /// **'Import game'**
  String get historyImportGame;

  /// No description provided for @historyOpenGallery.
  ///
  /// In en, this message translates to:
  /// **'Open gallery'**
  String get historyOpenGallery;

  /// No description provided for @historySearchAGamePlayerOr.
  ///
  /// In en, this message translates to:
  /// **'Search a game, player or date'**
  String get historySearchAGamePlayerOr;

  /// No description provided for @historyNoGamesFound.
  ///
  /// In en, this message translates to:
  /// **'No games found'**
  String get historyNoGamesFound;

  /// No description provided for @historyGamesAppearHereWhenCreated.
  ///
  /// In en, this message translates to:
  /// **'Games appear here when created.'**
  String get historyGamesAppearHereWhenCreated;

  /// No description provided for @historyCompletedGames.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED GAMES'**
  String get historyCompletedGames;

  /// No description provided for @historyActiveTables.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE TABLES'**
  String get historyActiveTables;

  /// No description provided for @historyMinutesPlayed.
  ///
  /// In en, this message translates to:
  /// **'MINUTES PLAYED'**
  String get historyMinutesPlayed;

  /// No description provided for @historyRestoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore backup?'**
  String get historyRestoreBackup;

  /// No description provided for @historyYourCurrentLibraryWillBe.
  ///
  /// In en, this message translates to:
  /// **'Your current library will be replaced. Export it first if needed.'**
  String get historyYourCurrentLibraryWillBe;

  /// No description provided for @historyBackupRestored.
  ///
  /// In en, this message translates to:
  /// **'Backup restored'**
  String get historyBackupRestored;

  /// No description provided for @historyEraseAllData.
  ///
  /// In en, this message translates to:
  /// **'Erase all data?'**
  String get historyEraseAllData;

  /// No description provided for @historyGamesTemplatesProfilesAndSettings.
  ///
  /// In en, this message translates to:
  /// **'Games, templates, profiles and settings will be removed from this device. This cannot be undone.'**
  String get historyGamesTemplatesProfilesAndSettings;

  /// No description provided for @historyYourDataBelongsToYou.
  ///
  /// In en, this message translates to:
  /// **'Your data belongs to you'**
  String get historyYourDataBelongsToYou;

  /// No description provided for @historyBackUpEverything.
  ///
  /// In en, this message translates to:
  /// **'Back up everything'**
  String get historyBackUpEverything;

  /// No description provided for @historyRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get historyRestore;

  /// No description provided for @historyEraseAllMyData.
  ///
  /// In en, this message translates to:
  /// **'Erase all my data'**
  String get historyEraseAllMyData;

  /// No description provided for @libraryGameShelf.
  ///
  /// In en, this message translates to:
  /// **'Game shelf'**
  String get libraryGameShelf;

  /// No description provided for @libraryMyGames.
  ///
  /// In en, this message translates to:
  /// **'My games'**
  String get libraryMyGames;

  /// No description provided for @libraryBoxesStoredOnThisDevice.
  ///
  /// In en, this message translates to:
  /// **'{count} boxes stored on this device.'**
  String libraryBoxesStoredOnThisDevice(Object count);

  /// No description provided for @libraryAddAGame.
  ///
  /// In en, this message translates to:
  /// **'Add a game'**
  String get libraryAddAGame;

  /// No description provided for @libraryEmptyShelves.
  ///
  /// In en, this message translates to:
  /// **'Empty shelves'**
  String get libraryEmptyShelves;

  /// No description provided for @libraryNoGameFound.
  ///
  /// In en, this message translates to:
  /// **'No game found'**
  String get libraryNoGameFound;

  /// No description provided for @libraryStoreYourBoxesHereTo.
  ///
  /// In en, this message translates to:
  /// **'Store your boxes here to find your games, packs and reviews.'**
  String get libraryStoreYourBoxesHereTo;

  /// No description provided for @libraryWhatToPlay.
  ///
  /// In en, this message translates to:
  /// **'What to play?'**
  String get libraryWhatToPlay;

  /// No description provided for @libraryReceiveByQr.
  ///
  /// In en, this message translates to:
  /// **'Receive by QR'**
  String get libraryReceiveByQr;

  /// No description provided for @libraryShareASession.
  ///
  /// In en, this message translates to:
  /// **'Share a session'**
  String get libraryShareASession;

  /// No description provided for @libraryPacksAndTemplates.
  ///
  /// In en, this message translates to:
  /// **'Packs and templates'**
  String get libraryPacksAndTemplates;

  /// No description provided for @librarySearchAGame.
  ///
  /// In en, this message translates to:
  /// **'Search a game'**
  String get librarySearchAGame;

  /// No description provided for @libraryNameTheGame.
  ///
  /// In en, this message translates to:
  /// **'Name the game.'**
  String get libraryNameTheGame;

  /// No description provided for @libraryShelfGame.
  ///
  /// In en, this message translates to:
  /// **'Shelf game'**
  String get libraryShelfGame;

  /// No description provided for @libraryGameName.
  ///
  /// In en, this message translates to:
  /// **'Game name'**
  String get libraryGameName;

  /// No description provided for @libraryGenres.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get libraryGenres;

  /// No description provided for @libraryBoxColour.
  ///
  /// In en, this message translates to:
  /// **'Box colour'**
  String get libraryBoxColour;

  /// No description provided for @libraryLinkedPacks.
  ///
  /// In en, this message translates to:
  /// **'Linked packs'**
  String get libraryLinkedPacks;

  /// No description provided for @libraryPutOnShelf.
  ///
  /// In en, this message translates to:
  /// **'Put on shelf'**
  String get libraryPutOnShelf;

  /// No description provided for @libraryPlayers.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get libraryPlayers;

  /// No description provided for @libraryLength.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get libraryLength;

  /// No description provided for @libraryColour.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get libraryColour;

  /// No description provided for @libraryImportBgg.
  ///
  /// In en, this message translates to:
  /// **'Import my BoardGameGeek collection'**
  String get libraryImportBgg;

  /// No description provided for @libraryImportUsername.
  ///
  /// In en, this message translates to:
  /// **'BoardGameGeek username'**
  String get libraryImportUsername;

  /// No description provided for @libraryImportDone.
  ///
  /// In en, this message translates to:
  /// **'Collection imported. Check your shelf.'**
  String get libraryImportDone;

  /// No description provided for @libraryImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed. Check the username and try again in a moment.'**
  String get libraryImportFailed;

  /// No description provided for @libraryStatsPlayed.
  ///
  /// In en, this message translates to:
  /// **'Played'**
  String get libraryStatsPlayed;

  /// No description provided for @libraryStatsNever.
  ///
  /// In en, this message translates to:
  /// **'Never played'**
  String get libraryStatsNever;

  /// No description provided for @libraryViewShelf.
  ///
  /// In en, this message translates to:
  /// **'Shelf'**
  String get libraryViewShelf;

  /// No description provided for @libraryViewCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get libraryViewCards;

  /// No description provided for @libraryScanLookingUp.
  ///
  /// In en, this message translates to:
  /// **'Looking up…'**
  String get libraryScanLookingUp;

  /// No description provided for @libraryScanBox.
  ///
  /// In en, this message translates to:
  /// **'Scan a box'**
  String get libraryScanBox;

  /// No description provided for @libraryScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan a barcode'**
  String get libraryScanTitle;

  /// No description provided for @libraryScanHint.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the barcode on the box, or type the number below.'**
  String get libraryScanHint;

  /// No description provided for @libraryScanUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable. Type the code instead.'**
  String get libraryScanUnavailable;

  /// No description provided for @libraryScanCodeField.
  ///
  /// In en, this message translates to:
  /// **'Barcode number'**
  String get libraryScanCodeField;

  /// No description provided for @libraryScanLookUp.
  ///
  /// In en, this message translates to:
  /// **'Look up'**
  String get libraryScanLookUp;

  /// No description provided for @libraryScanOwned.
  ///
  /// In en, this message translates to:
  /// **'Already on your shelf'**
  String get libraryScanOwned;

  /// No description provided for @libraryScanOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get libraryScanOpen;

  /// No description provided for @libraryScanFound.
  ///
  /// In en, this message translates to:
  /// **'Game found. Check it and put it on the shelf.'**
  String get libraryScanFound;

  /// No description provided for @libraryScanUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown code. Fill in the game, the code will be remembered.'**
  String get libraryScanUnknown;

  /// No description provided for @libraryScanOffline.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the lookup service. Fill in the game by hand.'**
  String get libraryScanOffline;

  /// No description provided for @libraryScanCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter 8 to 14 digits.'**
  String get libraryScanCodeInvalid;

  /// No description provided for @librarySearchOnline.
  ///
  /// In en, this message translates to:
  /// **'Search online by name'**
  String get librarySearchOnline;

  /// No description provided for @libraryBarcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode (EAN/UPC)'**
  String get libraryBarcode;

  /// No description provided for @libraryStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get libraryStatus;

  /// No description provided for @libraryStatusOwned.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get libraryStatusOwned;

  /// No description provided for @libraryStatusWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get libraryStatusWishlist;

  /// No description provided for @libraryStatusLent.
  ///
  /// In en, this message translates to:
  /// **'Lent out'**
  String get libraryStatusLent;

  /// No description provided for @libraryPlays.
  ///
  /// In en, this message translates to:
  /// **'plays'**
  String get libraryPlays;

  /// No description provided for @libraryRemoveThisGame.
  ///
  /// In en, this message translates to:
  /// **'Remove this game?'**
  String get libraryRemoveThisGame;

  /// No description provided for @libraryPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get libraryPlay;

  /// No description provided for @libraryRemoveFromShelf.
  ///
  /// In en, this message translates to:
  /// **'Remove from shelf'**
  String get libraryRemoveFromShelf;

  /// No description provided for @libraryWhatToPlayTonight.
  ///
  /// In en, this message translates to:
  /// **'What to play tonight?'**
  String get libraryWhatToPlayTonight;

  /// No description provided for @libraryWhoIsHere.
  ///
  /// In en, this message translates to:
  /// **'Who is here?'**
  String get libraryWhoIsHere;

  /// No description provided for @libraryAddFriends.
  ///
  /// In en, this message translates to:
  /// **'Add friends'**
  String get libraryAddFriends;

  /// No description provided for @libraryTimeAvailable.
  ///
  /// In en, this message translates to:
  /// **'Time available'**
  String get libraryTimeAvailable;

  /// No description provided for @libraryAllEvening.
  ///
  /// In en, this message translates to:
  /// **'All evening'**
  String get libraryAllEvening;

  /// No description provided for @libraryGamesForPlayers.
  ///
  /// In en, this message translates to:
  /// **'{count} games for {value} players'**
  String libraryGamesForPlayers(Object count, Object value);

  /// No description provided for @libraryNothingFits.
  ///
  /// In en, this message translates to:
  /// **'Nothing fits'**
  String get libraryNothingFits;

  /// No description provided for @libraryAddGamesOrRelaxYour.
  ///
  /// In en, this message translates to:
  /// **'Add games or relax your friends’ tastes.'**
  String get libraryAddGamesOrRelaxYour;

  /// No description provided for @libraryWantedBy.
  ///
  /// In en, this message translates to:
  /// **'Wanted by {value}'**
  String libraryWantedBy(Object value);

  /// No description provided for @libraryLovedBy.
  ///
  /// In en, this message translates to:
  /// **'Loved by {value}'**
  String libraryLovedBy(Object value);

  /// No description provided for @lobbySkullNight.
  ///
  /// In en, this message translates to:
  /// **'Skull night'**
  String get lobbySkullNight;

  /// No description provided for @lobbySeats.
  ///
  /// In en, this message translates to:
  /// **'Seats: {seats}'**
  String lobbySeats(Object seats);

  /// No description provided for @lobbyOpenTheLobby.
  ///
  /// In en, this message translates to:
  /// **'Open the lobby'**
  String get lobbyOpenTheLobby;

  /// No description provided for @lobbySameWiFi.
  ///
  /// In en, this message translates to:
  /// **'Same Wi-Fi'**
  String get lobbySameWiFi;

  /// No description provided for @lobbyAroundTheTableNoServer.
  ///
  /// In en, this message translates to:
  /// **'Around the table, no server.'**
  String get lobbyAroundTheTableNoServer;

  /// No description provided for @lobbyNotAvailableInTheBrowser.
  ///
  /// In en, this message translates to:
  /// **'Not available in the browser.'**
  String get lobbyNotAvailableInTheBrowser;

  /// No description provided for @lobbyRemote.
  ///
  /// In en, this message translates to:
  /// **'Remote'**
  String get lobbyRemote;

  /// No description provided for @lobbyOverTheInternetWithThe.
  ///
  /// In en, this message translates to:
  /// **'Over the Internet, with the link or code.'**
  String get lobbyOverTheInternetWithThe;

  /// No description provided for @lobbyNoServerConfiguredForThis.
  ///
  /// In en, this message translates to:
  /// **'No server configured for this build.'**
  String get lobbyNoServerConfiguredForThis;

  /// No description provided for @lobbyAcceptRequests.
  ///
  /// In en, this message translates to:
  /// **'Accept requests'**
  String get lobbyAcceptRequests;

  /// No description provided for @lobbyStartWithPlayers.
  ///
  /// In en, this message translates to:
  /// **'Start with {count} players'**
  String lobbyStartWithPlayers(Object count);

  /// No description provided for @lobbyCloseTheLobby.
  ///
  /// In en, this message translates to:
  /// **'Close the lobby'**
  String get lobbyCloseTheLobby;

  /// No description provided for @lobbyJoin.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get lobbyJoin;

  /// No description provided for @lobbyEnterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get lobbyEnterYourName;

  /// No description provided for @lobbyCodeOrLink.
  ///
  /// In en, this message translates to:
  /// **'Code or link'**
  String get lobbyCodeOrLink;

  /// No description provided for @lobbyScanAQr.
  ///
  /// In en, this message translates to:
  /// **'Scan a QR'**
  String get lobbyScanAQr;

  /// No description provided for @lobbyCameraUnavailableTypeTheCode.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable: type the code.'**
  String get lobbyCameraUnavailableTypeTheCode;

  /// No description provided for @lobbyTheHostClosedTheLobby.
  ///
  /// In en, this message translates to:
  /// **'The host closed the lobby.'**
  String get lobbyTheHostClosedTheLobby;

  /// No description provided for @lobbyHereWeGoTheGame.
  ///
  /// In en, this message translates to:
  /// **'Here we go! The game runs on {hostName}’s device.'**
  String lobbyHereWeGoTheGame(Object hostName);

  /// No description provided for @lobbyYouAreInWaitFor.
  ///
  /// In en, this message translates to:
  /// **'You are in. Wait for the start.'**
  String get lobbyYouAreInWaitFor;

  /// No description provided for @lobbyTheHostDidNotAccept.
  ///
  /// In en, this message translates to:
  /// **'The host did not accept your request.'**
  String get lobbyTheHostDidNotAccept;

  /// No description provided for @lobbyRequestSentTo.
  ///
  /// In en, this message translates to:
  /// **'Request sent to {hostName}…'**
  String lobbyRequestSentTo(Object hostName);

  /// No description provided for @lobbyLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get lobbyLeave;

  /// No description provided for @lobbyPlayers.
  ///
  /// In en, this message translates to:
  /// **'Players {count}/{seats}'**
  String lobbyPlayers(Object count, Object seats);

  /// No description provided for @lobbyHost.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get lobbyHost;

  /// No description provided for @lobbyRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get lobbyRequests;

  /// No description provided for @lobbyWantsToJoin.
  ///
  /// In en, this message translates to:
  /// **'Wants to join'**
  String get lobbyWantsToJoin;

  /// No description provided for @lobbyNoSeatLeft.
  ///
  /// In en, this message translates to:
  /// **'No seat left'**
  String get lobbyNoSeatLeft;

  /// No description provided for @lobbyAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept {name}'**
  String lobbyAccept(Object name);

  /// No description provided for @lobbyRefuse.
  ///
  /// In en, this message translates to:
  /// **'Refuse {name}'**
  String lobbyRefuse(Object name);

  /// No description provided for @lobbyRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String lobbyRemove(Object name);

  /// No description provided for @lobbyCheckTheCodeAndYour.
  ///
  /// In en, this message translates to:
  /// **'Check the code and your name.'**
  String get lobbyCheckTheCodeAndYour;

  /// No description provided for @lobbyNoOpenGameWithThis.
  ///
  /// In en, this message translates to:
  /// **'No open game with this code. Has the host opened the lobby?'**
  String get lobbyNoOpenGameWithThis;

  /// No description provided for @lobbyCannotConnectJoinTheSame.
  ///
  /// In en, this message translates to:
  /// **'Cannot connect: join the same Wi-Fi or turn on Internet.'**
  String get lobbyCannotConnectJoinTheSame;

  /// No description provided for @lobbySomethingWentWrongTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong, try again.'**
  String get lobbySomethingWentWrongTryAgain;

  /// No description provided for @memoriesGalleryKey.
  ///
  /// In en, this message translates to:
  /// **'Gallery key'**
  String get memoriesGalleryKey;

  /// No description provided for @memoriesLetYourFriendsScanThis.
  ///
  /// In en, this message translates to:
  /// **'Let your friends scan this code. Without it, the file stays unreadable.'**
  String get memoriesLetYourFriendsScanThis;

  /// No description provided for @memoriesKeyQrCode.
  ///
  /// In en, this message translates to:
  /// **'Key QR code'**
  String get memoriesKeyQrCode;

  /// No description provided for @memoriesDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get memoriesDone;

  /// No description provided for @memoriesShareEncrypted.
  ///
  /// In en, this message translates to:
  /// **'Share encrypted'**
  String get memoriesShareEncrypted;

  /// No description provided for @memoriesOpenAGallery.
  ///
  /// In en, this message translates to:
  /// **'Open a gallery'**
  String get memoriesOpenAGallery;

  /// No description provided for @memories1PickTheReceivedFile.
  ///
  /// In en, this message translates to:
  /// **'1. Pick the received file. 2. Scan the key shown by your friend.'**
  String get memories1PickTheReceivedFile;

  /// No description provided for @memoriesPickTheFile.
  ///
  /// In en, this message translates to:
  /// **'Pick the file'**
  String get memoriesPickTheFile;

  /// No description provided for @memoriesFileReady.
  ///
  /// In en, this message translates to:
  /// **'File ready ✓'**
  String get memoriesFileReady;

  /// No description provided for @memoriesScanTheKey.
  ///
  /// In en, this message translates to:
  /// **'Scan the key'**
  String get memoriesScanTheKey;

  /// No description provided for @memoriesCameraUnavailableTypeTheKey.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable. Type the key instead.'**
  String get memoriesCameraUnavailableTypeTheKey;

  /// No description provided for @memoriesDecrypt.
  ///
  /// In en, this message translates to:
  /// **'Decrypt'**
  String get memoriesDecrypt;

  /// No description provided for @memoriesTheStory.
  ///
  /// In en, this message translates to:
  /// **'The story'**
  String get memoriesTheStory;

  /// No description provided for @memoriesHighlights.
  ///
  /// In en, this message translates to:
  /// **'Highlights'**
  String get memoriesHighlights;

  /// No description provided for @memoriesPrivateGallery.
  ///
  /// In en, this message translates to:
  /// **'Private gallery'**
  String get memoriesPrivateGallery;

  /// No description provided for @memoriesStorySaved.
  ///
  /// In en, this message translates to:
  /// **'Story saved'**
  String get memoriesStorySaved;

  /// No description provided for @memoriesWhatWeLlRememberOf.
  ///
  /// In en, this message translates to:
  /// **'What we’ll remember of this night'**
  String get memoriesWhatWeLlRememberOf;

  /// No description provided for @memoriesSaveTheStory.
  ///
  /// In en, this message translates to:
  /// **'Save the story'**
  String get memoriesSaveTheStory;

  /// No description provided for @memoriesRemoveThisMoment.
  ///
  /// In en, this message translates to:
  /// **'Remove this moment'**
  String get memoriesRemoveThisMoment;

  /// No description provided for @memoriesAHighlightThenEnter.
  ///
  /// In en, this message translates to:
  /// **'A highlight, then Enter'**
  String get memoriesAHighlightThenEnter;

  /// No description provided for @memoriesPhotoTooLarge8Mb.
  ///
  /// In en, this message translates to:
  /// **'Photo too large (8 MB maximum).'**
  String get memoriesPhotoTooLarge8Mb;

  /// No description provided for @memories60PhotosMaximumPerGame.
  ///
  /// In en, this message translates to:
  /// **'60 photos maximum per game.'**
  String get memories60PhotosMaximumPerGame;

  /// No description provided for @memoriesPhotosStayOnThisDevice.
  ///
  /// In en, this message translates to:
  /// **'Photos stay on this device. To share them, the gallery is encrypted and the key is passed by QR code at the table.'**
  String get memoriesPhotosStayOnThisDevice;

  /// No description provided for @memoriesAddAPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get memoriesAddAPhoto;

  /// No description provided for @memoriesDeleteThePhoto.
  ///
  /// In en, this message translates to:
  /// **'Delete the photo?'**
  String get memoriesDeleteThePhoto;

  /// No description provided for @memoriesItWillBeErased.
  ///
  /// In en, this message translates to:
  /// **'It will be erased.'**
  String get memoriesItWillBeErased;

  /// No description provided for @memoriesGamePhoto.
  ///
  /// In en, this message translates to:
  /// **'Game photo'**
  String get memoriesGamePhoto;

  /// No description provided for @memoriesDeletePhoto.
  ///
  /// In en, this message translates to:
  /// **'Delete photo'**
  String get memoriesDeletePhoto;

  /// No description provided for @sharingReceivedGamesPacksSheets.
  ///
  /// In en, this message translates to:
  /// **'Received: {games} games, {templates} packs, {characters} sheets'**
  String sharingReceivedGamesPacksSheets(
    Object games,
    Object templates,
    Object characters,
  );

  /// No description provided for @sharingReceiveASession.
  ///
  /// In en, this message translates to:
  /// **'Receive a session'**
  String get sharingReceiveASession;

  /// No description provided for @sharingPointAtYourFriendS.
  ///
  /// In en, this message translates to:
  /// **'Point at your friend’s animated QR code and keep it framed until 100%.'**
  String get sharingPointAtYourFriendS;

  /// No description provided for @sharingCameraUnavailableAskForThe.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable. Ask for the file instead.'**
  String get sharingCameraUnavailableAskForThe;

  /// No description provided for @sharingReceiveProgress.
  ///
  /// In en, this message translates to:
  /// **'Receive progress'**
  String get sharingReceiveProgress;

  /// No description provided for @sharingWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting…'**
  String get sharingWaiting;

  /// No description provided for @sharingOpenAFile.
  ///
  /// In en, this message translates to:
  /// **'Open a file'**
  String get sharingOpenAFile;

  /// No description provided for @sharingYourFriendOpensReceiveBy.
  ///
  /// In en, this message translates to:
  /// **'Your friend opens “Receive by QR” and points at the screen: games, packs, dice and character sheets land on their device.'**
  String get sharingYourFriendOpensReceiveBy;

  /// No description provided for @sharingContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get sharingContent;

  /// No description provided for @sharingNothingToShare.
  ///
  /// In en, this message translates to:
  /// **'Nothing to share'**
  String get sharingNothingToShare;

  /// No description provided for @sharingPickAtLeastOneGame.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one game or pack.'**
  String get sharingPickAtLeastOneGame;

  /// No description provided for @sharingSessionQrCode.
  ///
  /// In en, this message translates to:
  /// **'Session QR code'**
  String get sharingSessionQrCode;

  /// No description provided for @sharingGamesPacksSheetsFrames.
  ///
  /// In en, this message translates to:
  /// **'{count} games · {count2} packs · {count3} sheets · {count4} frames'**
  String sharingGamesPacksSheetsFrames(
    Object count,
    Object count2,
    Object count3,
    Object count4,
  );

  /// No description provided for @sharingSendAsAFile.
  ///
  /// In en, this message translates to:
  /// **'Send as a file'**
  String get sharingSendAsAFile;

  /// No description provided for @timerTimeIsUpPassThe.
  ///
  /// In en, this message translates to:
  /// **'Time is up. Pass the turn.'**
  String get timerTimeIsUpPassThe;

  /// No description provided for @timerConfigureTime.
  ///
  /// In en, this message translates to:
  /// **'Configure time'**
  String get timerConfigureTime;

  /// No description provided for @timerApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get timerApply;

  /// No description provided for @timerTimeToThink.
  ///
  /// In en, this message translates to:
  /// **'TIME TO THINK'**
  String get timerTimeToThink;

  /// No description provided for @timerQuickTimer.
  ///
  /// In en, this message translates to:
  /// **'Quick timer'**
  String get timerQuickTimer;

  /// No description provided for @timerPlayerBank.
  ///
  /// In en, this message translates to:
  /// **'Player bank'**
  String get timerPlayerBank;

  /// No description provided for @timerTimePerTurn.
  ///
  /// In en, this message translates to:
  /// **'Time per turn'**
  String get timerTimePerTurn;

  /// No description provided for @timerTimeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Time remaining'**
  String get timerTimeRemaining;

  /// No description provided for @timerPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get timerPause;

  /// No description provided for @timerStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get timerStart;

  /// No description provided for @timerTimerSettings.
  ///
  /// In en, this message translates to:
  /// **'Timer settings'**
  String get timerTimerSettings;

  /// No description provided for @timerDurationInSeconds.
  ///
  /// In en, this message translates to:
  /// **'Duration in seconds'**
  String get timerDurationInSeconds;

  /// No description provided for @timerIncrementPerTurnSeconds.
  ///
  /// In en, this message translates to:
  /// **'Increment per turn (seconds)'**
  String get timerIncrementPerTurnSeconds;

  /// No description provided for @timerBankPerPlayer.
  ///
  /// In en, this message translates to:
  /// **'Bank per player'**
  String get timerBankPerPlayer;

  /// No description provided for @timerOtherwiseFixedTimeEachTurn.
  ///
  /// In en, this message translates to:
  /// **'Otherwise: fixed time each turn.'**
  String get timerOtherwiseFixedTimeEachTurn;

  /// No description provided for @timerTimeToPlay.
  ///
  /// In en, this message translates to:
  /// **'Time to play'**
  String get timerTimeToPlay;

  /// No description provided for @randomKeepCards.
  ///
  /// In en, this message translates to:
  /// **'Keep {range} card(s). {selected} selected.'**
  String randomKeepCards(String range, int selected);

  /// No description provided for @randomKeepRangeBetween.
  ///
  /// In en, this message translates to:
  /// **'{min} to {max}'**
  String randomKeepRangeBetween(int min, int max);

  /// No description provided for @randomPreviousStep.
  ///
  /// In en, this message translates to:
  /// **'Previous booster'**
  String get randomPreviousStep;

  /// No description provided for @toolPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Who starts?'**
  String get toolPickerTitle;

  /// No description provided for @toolPickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A finger or a name. Chance decides.'**
  String get toolPickerSubtitle;

  /// No description provided for @toolDiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Roll the dice'**
  String get toolDiceTitle;

  /// No description provided for @toolDiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Multiple dice, locking and expressions.'**
  String get toolDiceSubtitle;

  /// No description provided for @toolScoresTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep score'**
  String get toolScoresTitle;

  /// No description provided for @toolScoresSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scores, rounds and categories.'**
  String get toolScoresSubtitle;

  /// No description provided for @toolTimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep the tempo'**
  String get toolTimerTitle;

  /// No description provided for @toolTimerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Time per turn or a reserve per player.'**
  String get toolTimerSubtitle;

  /// No description provided for @toolTeamsTitle.
  ///
  /// In en, this message translates to:
  /// **'Make teams'**
  String get toolTeamsTitle;

  /// No description provided for @toolTeamsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'From 2 to many random teams.'**
  String get toolTeamsSubtitle;

  /// No description provided for @toolWheelTitle.
  ///
  /// In en, this message translates to:
  /// **'Spin the wheel'**
  String get toolWheelTitle;

  /// No description provided for @toolWheelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Custom options and probabilities.'**
  String get toolWheelSubtitle;

  /// No description provided for @toolCoinTitle.
  ///
  /// In en, this message translates to:
  /// **'Heads or tails'**
  String get toolCoinTitle;

  /// No description provided for @toolCoinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A decision in an instant.'**
  String get toolCoinSubtitle;

  /// No description provided for @toolOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn order'**
  String get toolOrderTitle;

  /// No description provided for @toolOrderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everyone gets their turn.'**
  String get toolOrderSubtitle;

  /// No description provided for @toolNumberTitle.
  ///
  /// In en, this message translates to:
  /// **'Random number'**
  String get toolNumberTitle;

  /// No description provided for @toolNumberSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A range, a result.'**
  String get toolNumberSubtitle;

  /// No description provided for @toolBagTitle.
  ///
  /// In en, this message translates to:
  /// **'Token bag'**
  String get toolBagTitle;

  /// No description provided for @toolBagSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Draw without replacement, then start again.'**
  String get toolBagSubtitle;

  /// No description provided for @toolRolesTitle.
  ///
  /// In en, this message translates to:
  /// **'Secret roles'**
  String get toolRolesTitle;

  /// No description provided for @toolRolesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One phone, roles to discover.'**
  String get toolRolesSubtitle;

  /// No description provided for @toolCharacterTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a character'**
  String get toolCharacterTitle;

  /// No description provided for @toolCharacterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Lists and boosters: your cards make a sheet.'**
  String get toolCharacterSubtitle;

  /// No description provided for @toolNpcTitle.
  ///
  /// In en, this message translates to:
  /// **'NPC generator'**
  String get toolNpcTitle;

  /// No description provided for @toolNpcSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A full NPC in one tap: look, personality, secret.'**
  String get toolNpcSubtitle;

  /// No description provided for @toolTavernTitle.
  ///
  /// In en, this message translates to:
  /// **'Tavern generator'**
  String get toolTavernTitle;

  /// No description provided for @toolTavernSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A whole tavern in a few taps: menu, rumours, staff.'**
  String get toolTavernSubtitle;

  /// No description provided for @toolEncounterTitle.
  ///
  /// In en, this message translates to:
  /// **'Random encounter'**
  String get toolEncounterTitle;

  /// No description provided for @toolEncounterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'An encounter with complications and a twist.'**
  String get toolEncounterSubtitle;

  /// No description provided for @toolCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get toolCategoryAll;

  /// No description provided for @toolCategoryChance.
  ///
  /// In en, this message translates to:
  /// **'Chance'**
  String get toolCategoryChance;

  /// No description provided for @toolCategoryMatch.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get toolCategoryMatch;

  /// No description provided for @toolCategoryTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get toolCategoryTime;

  /// No description provided for @toolCategoryStory.
  ///
  /// In en, this message translates to:
  /// **'Story'**
  String get toolCategoryStory;

  /// No description provided for @randomCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get randomCopy;

  /// No description provided for @randomCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get randomCopied;

  /// No description provided for @toolQuestTitle.
  ///
  /// In en, this message translates to:
  /// **'Quest generator'**
  String get toolQuestTitle;

  /// No description provided for @toolQuestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A hook, a place, an obstacle and a reward.'**
  String get toolQuestSubtitle;

  /// No description provided for @toolTreasureTitle.
  ///
  /// In en, this message translates to:
  /// **'Treasure generator'**
  String get toolTreasureTitle;

  /// No description provided for @toolTreasureSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What is inside the chest, and one odd curiosity.'**
  String get toolTreasureSubtitle;

  /// No description provided for @toolVillainTitle.
  ///
  /// In en, this message translates to:
  /// **'Villain generator'**
  String get toolVillainTitle;

  /// No description provided for @toolVillainSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Motive, methods, weakness and lair.'**
  String get toolVillainSubtitle;

  /// No description provided for @toolTownTitle.
  ///
  /// In en, this message translates to:
  /// **'Town generator'**
  String get toolTownTitle;

  /// No description provided for @toolTownSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A name, a trade, a landmark and some trouble.'**
  String get toolTownSubtitle;

  /// No description provided for @randomModeFirst.
  ///
  /// In en, this message translates to:
  /// **'Who goes first'**
  String get randomModeFirst;

  /// No description provided for @randomModeRank.
  ///
  /// In en, this message translates to:
  /// **'Rank everyone'**
  String get randomModeRank;

  /// No description provided for @randomRankingDone.
  ///
  /// In en, this message translates to:
  /// **'Everyone is ranked. Lift your fingers to start again.'**
  String get randomRankingDone;

  /// No description provided for @counterIncrease.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get counterIncrease;

  /// No description provided for @counterDecrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get counterDecrease;

  /// No description provided for @counterEliminated.
  ///
  /// In en, this message translates to:
  /// **'Eliminated'**
  String get counterEliminated;

  /// No description provided for @counterSkipsTurn.
  ///
  /// In en, this message translates to:
  /// **'Skips a turn'**
  String get counterSkipsTurn;

  /// No description provided for @toolDiceTrayTitle.
  ///
  /// In en, this message translates to:
  /// **'Dice tray'**
  String get toolDiceTrayTitle;

  /// No description provided for @toolDiceTraySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shake to throw, keep dice aside, see the total.'**
  String get toolDiceTraySubtitle;

  /// No description provided for @diceTrayThrow.
  ///
  /// In en, this message translates to:
  /// **'Throw'**
  String get diceTrayThrow;

  /// No description provided for @diceSkinCream.
  ///
  /// In en, this message translates to:
  /// **'Soft cream'**
  String get diceSkinCream;

  /// No description provided for @diceSkinViolet.
  ///
  /// In en, this message translates to:
  /// **'Soft violet'**
  String get diceSkinViolet;

  /// No description provided for @diceTableRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get diceTableRed;

  /// No description provided for @diceSeeMore.
  ///
  /// In en, this message translates to:
  /// **'See all dice'**
  String get diceSeeMore;

  /// No description provided for @diceFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get diceFavorites;

  /// No description provided for @diceFavoriteAdd.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get diceFavoriteAdd;

  /// No description provided for @diceFavoriteRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get diceFavoriteRemove;

  /// No description provided for @diceTrayErase.
  ///
  /// In en, this message translates to:
  /// **'Clear result'**
  String get diceTrayErase;

  /// No description provided for @diceTrayShareResult.
  ///
  /// In en, this message translates to:
  /// **'Share result'**
  String get diceTrayShareResult;

  /// No description provided for @diceMoreDice.
  ///
  /// In en, this message translates to:
  /// **'More dice'**
  String get diceMoreDice;

  /// No description provided for @diceResultMode.
  ///
  /// In en, this message translates to:
  /// **'Result display'**
  String get diceResultMode;

  /// No description provided for @diceResultNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get diceResultNone;

  /// No description provided for @diceResultList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get diceResultList;

  /// No description provided for @diceResultCombined.
  ///
  /// In en, this message translates to:
  /// **'Combined'**
  String get diceResultCombined;

  /// No description provided for @diceResultSum.
  ///
  /// In en, this message translates to:
  /// **'Sum'**
  String get diceResultSum;

  /// No description provided for @diceResultBest.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get diceResultBest;

  /// No description provided for @diceResultWorst.
  ///
  /// In en, this message translates to:
  /// **'Worst'**
  String get diceResultWorst;

  /// No description provided for @diceResultDropWorst.
  ///
  /// In en, this message translates to:
  /// **'Drop lowest'**
  String get diceResultDropWorst;

  /// No description provided for @diceResultDropBest.
  ///
  /// In en, this message translates to:
  /// **'Drop highest'**
  String get diceResultDropBest;

  /// No description provided for @diceResultMiddle.
  ///
  /// In en, this message translates to:
  /// **'Middle'**
  String get diceResultMiddle;

  /// No description provided for @diceResultAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get diceResultAverage;

  /// No description provided for @diceResultOddEven.
  ///
  /// In en, this message translates to:
  /// **'Odd / even'**
  String get diceResultOddEven;

  /// No description provided for @diceResultOddEvenCount.
  ///
  /// In en, this message translates to:
  /// **'{odd} odd · {even} even'**
  String diceResultOddEvenCount(int odd, int even);

  /// No description provided for @diceTrayShakeHint.
  ///
  /// In en, this message translates to:
  /// **'Shake your phone or press Throw.'**
  String get diceTrayShakeHint;

  /// No description provided for @diceTrayTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get diceTrayTotal;

  /// No description provided for @diceTrayHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get diceTrayHistory;

  /// No description provided for @diceTrayKeepHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a die to keep it aside.'**
  String get diceTrayKeepHint;

  /// No description provided for @diceTrayKept.
  ///
  /// In en, this message translates to:
  /// **'Kept aside'**
  String get diceTrayKept;

  /// No description provided for @diceTrayAddDie.
  ///
  /// In en, this message translates to:
  /// **'Add a die'**
  String get diceTrayAddDie;

  /// No description provided for @diceTrayRemoveDie.
  ///
  /// In en, this message translates to:
  /// **'Remove this die'**
  String get diceTrayRemoveDie;

  /// No description provided for @diceTrayCustomFaces.
  ///
  /// In en, this message translates to:
  /// **'Custom faces, comma-separated'**
  String get diceTrayCustomFaces;

  /// No description provided for @diceTrayCustomDie.
  ///
  /// In en, this message translates to:
  /// **'Custom die'**
  String get diceTrayCustomDie;

  /// No description provided for @diceTrayEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add a die to start.'**
  String get diceTrayEmpty;

  /// No description provided for @diceTrayCustomColor.
  ///
  /// In en, this message translates to:
  /// **'Face color'**
  String get diceTrayCustomColor;

  /// No description provided for @diceTraySurface.
  ///
  /// In en, this message translates to:
  /// **'Surface'**
  String get diceTraySurface;

  /// No description provided for @diceTrayWood.
  ///
  /// In en, this message translates to:
  /// **'Wood'**
  String get diceTrayWood;

  /// No description provided for @diceTrayFelt.
  ///
  /// In en, this message translates to:
  /// **'Felt'**
  String get diceTrayFelt;

  /// No description provided for @diceTrayGlass.
  ///
  /// In en, this message translates to:
  /// **'Glass'**
  String get diceTrayGlass;

  /// No description provided for @toolHourglassTitle.
  ///
  /// In en, this message translates to:
  /// **'Hourglass'**
  String get toolHourglassTitle;

  /// No description provided for @toolHourglassSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sand that measures a turn, then flips.'**
  String get toolHourglassSubtitle;

  /// No description provided for @hourglassTurn.
  ///
  /// In en, this message translates to:
  /// **'Turn'**
  String get hourglassTurn;

  /// No description provided for @hourglassStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get hourglassStart;

  /// No description provided for @hourglassPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get hourglassPause;

  /// No description provided for @hourglassDone.
  ///
  /// In en, this message translates to:
  /// **'Time is up'**
  String get hourglassDone;

  /// No description provided for @hourglassSeconds.
  ///
  /// In en, this message translates to:
  /// **'{count} s'**
  String hourglassSeconds(int count);

  /// No description provided for @toolHeroesTitle.
  ///
  /// In en, this message translates to:
  /// **'Heroes and powers'**
  String get toolHeroesTitle;

  /// No description provided for @toolHeroesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Heroes with counters and powers that charge up.'**
  String get toolHeroesSubtitle;

  /// No description provided for @heroesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No hero yet. Add one to start.'**
  String get heroesEmpty;

  /// No description provided for @heroesAddHero.
  ///
  /// In en, this message translates to:
  /// **'Add a hero'**
  String get heroesAddHero;

  /// No description provided for @heroesHeroName.
  ///
  /// In en, this message translates to:
  /// **'Hero name'**
  String get heroesHeroName;

  /// No description provided for @heroesAddPower.
  ///
  /// In en, this message translates to:
  /// **'Add a power'**
  String get heroesAddPower;

  /// No description provided for @heroesPowerName.
  ///
  /// In en, this message translates to:
  /// **'Power name'**
  String get heroesPowerName;

  /// No description provided for @heroesUse.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get heroesUse;

  /// No description provided for @heroesCharging.
  ///
  /// In en, this message translates to:
  /// **'Charging'**
  String get heroesCharging;

  /// No description provided for @heroesReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get heroesReady;

  /// No description provided for @heroesUsed.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get heroesUsed;

  /// No description provided for @heroesCharge.
  ///
  /// In en, this message translates to:
  /// **'Add a charge'**
  String get heroesCharge;

  /// No description provided for @heroesRecharge.
  ///
  /// In en, this message translates to:
  /// **'Recharge'**
  String get heroesRecharge;

  /// No description provided for @heroesActive.
  ///
  /// In en, this message translates to:
  /// **'Active hero'**
  String get heroesActive;

  /// No description provided for @heroesMakeActive.
  ///
  /// In en, this message translates to:
  /// **'Make active'**
  String get heroesMakeActive;

  /// No description provided for @toolMagicItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Magic item generator'**
  String get toolMagicItemTitle;

  /// No description provided for @toolMagicItemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A relic with a power, a quirk and an origin.'**
  String get toolMagicItemSubtitle;

  /// No description provided for @toolWeatherTitle.
  ///
  /// In en, this message translates to:
  /// **'Weather generator'**
  String get toolWeatherTitle;

  /// No description provided for @toolWeatherSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sky, temperature, wind, effects and omens.'**
  String get toolWeatherSubtitle;

  /// No description provided for @toolPlaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Place name generator'**
  String get toolPlaceTitle;

  /// No description provided for @toolPlaceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A name, a kind of place and a striking feature.'**
  String get toolPlaceSubtitle;

  /// No description provided for @toolDilemmaTitle.
  ///
  /// In en, this message translates to:
  /// **'Moral dilemma generator'**
  String get toolDilemmaTitle;

  /// No description provided for @toolDilemmaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A tough situation, two choices and the price to pay.'**
  String get toolDilemmaSubtitle;

  /// No description provided for @toolRumourTitle.
  ///
  /// In en, this message translates to:
  /// **'Tavern rumour generator'**
  String get toolRumourTitle;

  /// No description provided for @toolRumourSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Who said it, what they said and how true it is.'**
  String get toolRumourSubtitle;

  /// No description provided for @toolTraitTitle.
  ///
  /// In en, this message translates to:
  /// **'NPC trait generator'**
  String get toolTraitTitle;

  /// No description provided for @toolTraitSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A personality trait, how it shows and a hidden flaw.'**
  String get toolTraitSubtitle;

  /// No description provided for @toolTwistTitle.
  ///
  /// In en, this message translates to:
  /// **'Plot twist generator'**
  String get toolTwistTitle;

  /// No description provided for @toolTwistSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A twist, an early clue and its consequence.'**
  String get toolTwistSubtitle;

  /// No description provided for @templatesShareCompanion.
  ///
  /// In en, this message translates to:
  /// **'Share companion file (bricks and settings only)'**
  String get templatesShareCompanion;

  /// No description provided for @templatesImportCompanion.
  ///
  /// In en, this message translates to:
  /// **'Import companion file'**
  String get templatesImportCompanion;

  /// No description provided for @templatesCompanionImported.
  ///
  /// In en, this message translates to:
  /// **'Companion imported'**
  String get templatesCompanionImported;

  /// No description provided for @companionErrorNotJson.
  ///
  /// In en, this message translates to:
  /// **'This file is not valid JSON.'**
  String get companionErrorNotJson;

  /// No description provided for @companionErrorFormat.
  ///
  /// In en, this message translates to:
  /// **'This is not an Amiludo companion file.'**
  String get companionErrorFormat;

  /// No description provided for @companionErrorVersion.
  ///
  /// In en, this message translates to:
  /// **'This companion file version is not supported.'**
  String get companionErrorVersion;

  /// No description provided for @companionErrorInvalid.
  ///
  /// In en, this message translates to:
  /// **'The companion file content is invalid.'**
  String get companionErrorInvalid;

  /// No description provided for @companionErrorReserved.
  ///
  /// In en, this message translates to:
  /// **'This identifier is reserved for a built-in template.'**
  String get companionErrorReserved;

  /// No description provided for @brickLibrarySearch.
  ///
  /// In en, this message translates to:
  /// **'Search a brick'**
  String get brickLibrarySearch;

  /// No description provided for @brickLibraryNone.
  ///
  /// In en, this message translates to:
  /// **'No brick for this search.'**
  String get brickLibraryNone;

  /// No description provided for @toolCategoryFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get toolCategoryFavorites;

  /// No description provided for @toolCategoryCounters.
  ///
  /// In en, this message translates to:
  /// **'Counters'**
  String get toolCategoryCounters;

  /// No description provided for @brickAddToCompanion.
  ///
  /// In en, this message translates to:
  /// **'Add to a companion'**
  String get brickAddToCompanion;

  /// No description provided for @brickChooseCompanion.
  ///
  /// In en, this message translates to:
  /// **'Choose a companion'**
  String get brickChooseCompanion;

  /// No description provided for @brickNoCompanion.
  ///
  /// In en, this message translates to:
  /// **'Create a companion in Templates first.'**
  String get brickNoCompanion;

  /// No description provided for @brickAdded.
  ///
  /// In en, this message translates to:
  /// **'Brick added to the companion.'**
  String get brickAdded;

  /// No description provided for @brickSettings.
  ///
  /// In en, this message translates to:
  /// **'Brick settings'**
  String get brickSettings;

  /// No description provided for @brickSettingName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get brickSettingName;

  /// No description provided for @brickSettingMinimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get brickSettingMinimum;

  /// No description provided for @brickSettingMaximum.
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get brickSettingMaximum;

  /// No description provided for @brickSettingStart.
  ///
  /// In en, this message translates to:
  /// **'Start value'**
  String get brickSettingStart;

  /// No description provided for @brickSettingStep.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get brickSettingStep;

  /// No description provided for @brickSettingColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get brickSettingColor;

  /// No description provided for @brickSettingDisplay.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get brickSettingDisplay;

  /// No description provided for @brickDisplayNumber.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get brickDisplayNumber;

  /// No description provided for @brickDisplayBar.
  ///
  /// In en, this message translates to:
  /// **'Bar'**
  String get brickDisplayBar;

  /// No description provided for @brickDisplayHearts.
  ///
  /// In en, this message translates to:
  /// **'Hearts'**
  String get brickDisplayHearts;

  /// No description provided for @brickDisplayPips.
  ///
  /// In en, this message translates to:
  /// **'Pips'**
  String get brickDisplayPips;

  /// No description provided for @brickSettingsApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get brickSettingsApply;

  /// No description provided for @brickColorBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get brickColorBlue;

  /// No description provided for @brickColorRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get brickColorRed;

  /// No description provided for @brickColorGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get brickColorGold;

  /// No description provided for @brickColorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get brickColorGreen;

  /// No description provided for @brickColorViolet.
  ///
  /// In en, this message translates to:
  /// **'Violet'**
  String get brickColorViolet;

  /// No description provided for @toolCounterLifeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Lives or health, with a bar.'**
  String get toolCounterLifeSubtitle;

  /// No description provided for @toolCounterPointsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Points to add up, round after round.'**
  String get toolCounterPointsSubtitle;

  /// No description provided for @toolCounterChipsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A stack of chips to bet and win.'**
  String get toolCounterChipsSubtitle;

  /// No description provided for @toolCounterPotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The shared pot everyone plays for.'**
  String get toolCounterPotSubtitle;

  /// No description provided for @campaignTitle.
  ///
  /// In en, this message translates to:
  /// **'Role-playing initiation'**
  String get campaignTitle;

  /// No description provided for @campaignHomeTile.
  ///
  /// In en, this message translates to:
  /// **'Learn role-playing'**
  String get campaignHomeTile;

  /// No description provided for @campaignSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A short story in {universe}, one mission at a time.'**
  String campaignSubtitle(String universe);

  /// No description provided for @campaignProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} missions'**
  String campaignProgress(int done, int total);

  /// No description provided for @campaignMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String campaignMinutes(int count);

  /// No description provided for @campaignLocked.
  ///
  /// In en, this message translates to:
  /// **'Finish the previous mission to unlock this one.'**
  String get campaignLocked;

  /// No description provided for @campaignStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get campaignStart;

  /// No description provided for @campaignReplay.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get campaignReplay;

  /// No description provided for @campaignConcept.
  ///
  /// In en, this message translates to:
  /// **'What you learn'**
  String get campaignConcept;

  /// No description provided for @campaignYourTurn.
  ///
  /// In en, this message translates to:
  /// **'Your turn'**
  String get campaignYourTurn;

  /// No description provided for @campaignComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete the mission'**
  String get campaignComplete;

  /// No description provided for @campaignCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mission complete'**
  String get campaignCompleted;

  /// No description provided for @campaignBadgeEarned.
  ///
  /// In en, this message translates to:
  /// **'Badge earned'**
  String get campaignBadgeEarned;

  /// No description provided for @campaignBadges.
  ///
  /// In en, this message translates to:
  /// **'Your badges'**
  String get campaignBadges;

  /// No description provided for @campaignNoBadges.
  ///
  /// In en, this message translates to:
  /// **'Complete a mission to earn your first badge.'**
  String get campaignNoBadges;

  /// No description provided for @campaignNext.
  ///
  /// In en, this message translates to:
  /// **'Next mission'**
  String get campaignNext;

  /// No description provided for @campaignToList.
  ///
  /// In en, this message translates to:
  /// **'All missions'**
  String get campaignToList;

  /// No description provided for @campaignReset.
  ///
  /// In en, this message translates to:
  /// **'Restart the campaign'**
  String get campaignReset;

  /// No description provided for @campaignChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose your way'**
  String get campaignChoose;

  /// No description provided for @campaignFinale.
  ///
  /// In en, this message translates to:
  /// **'The lantern shines again over {universe}. You are ready to play your first role-playing game.'**
  String campaignFinale(String universe);

  /// No description provided for @campaignM1Title.
  ///
  /// In en, this message translates to:
  /// **'The door that sticks'**
  String get campaignM1Title;

  /// No description provided for @campaignM1Story.
  ///
  /// In en, this message translates to:
  /// **'Night falls. The old gate of the lantern tower is stuck. In a role-playing game, when the outcome is uncertain, you roll the dice.'**
  String get campaignM1Story;

  /// No description provided for @campaignM1Lesson.
  ///
  /// In en, this message translates to:
  /// **'A check: roll a die and compare the result to a target.'**
  String get campaignM1Lesson;

  /// No description provided for @campaignM1Task.
  ///
  /// In en, this message translates to:
  /// **'Throw the dice below. A 4 or more opens the gate. Otherwise, try again.'**
  String get campaignM1Task;

  /// No description provided for @campaignM1Badge.
  ///
  /// In en, this message translates to:
  /// **'Gate opener'**
  String get campaignM1Badge;

  /// No description provided for @campaignM2Title.
  ///
  /// In en, this message translates to:
  /// **'A fragile lantern'**
  String get campaignM2Title;

  /// No description provided for @campaignM2Story.
  ///
  /// In en, this message translates to:
  /// **'Inside, the lantern shakes and every shock cracks its glass. Your hero has life points too, and the game keeps track of them.'**
  String get campaignM2Story;

  /// No description provided for @campaignM2Lesson.
  ///
  /// In en, this message translates to:
  /// **'Life points go down when you are hurt and up when you heal.'**
  String get campaignM2Lesson;

  /// No description provided for @campaignM2Task.
  ///
  /// In en, this message translates to:
  /// **'Use the hearts below: lose two for the shocks, then win one back by resting.'**
  String get campaignM2Task;

  /// No description provided for @campaignM2Badge.
  ///
  /// In en, this message translates to:
  /// **'Keeper of hearts'**
  String get campaignM2Badge;

  /// No description provided for @campaignM3Title.
  ///
  /// In en, this message translates to:
  /// **'Who are you?'**
  String get campaignM3Title;

  /// No description provided for @campaignM3Story.
  ///
  /// In en, this message translates to:
  /// **'A voice asks your name. Every hero has a name, strengths and a few powers, all written on a character sheet.'**
  String get campaignM3Story;

  /// No description provided for @campaignM3Lesson.
  ///
  /// In en, this message translates to:
  /// **'A character sheet gathers everything that makes your hero unique.'**
  String get campaignM3Lesson;

  /// No description provided for @campaignM3Task.
  ///
  /// In en, this message translates to:
  /// **'Add a hero with a name, then give it a power.'**
  String get campaignM3Task;

  /// No description provided for @campaignM3Badge.
  ///
  /// In en, this message translates to:
  /// **'Hero with a name'**
  String get campaignM3Badge;

  /// No description provided for @campaignM4Title.
  ///
  /// In en, this message translates to:
  /// **'The shadow in the hall'**
  String get campaignM4Title;

  /// No description provided for @campaignM4Story.
  ///
  /// In en, this message translates to:
  /// **'A shadow blocks the stairs. A fight is just a series of rolls, each hit costing the enemy a little life.'**
  String get campaignM4Story;

  /// No description provided for @campaignM4Lesson.
  ///
  /// In en, this message translates to:
  /// **'In a fight, you take turns rolling and lowering life points.'**
  String get campaignM4Lesson;

  /// No description provided for @campaignM4Task.
  ///
  /// In en, this message translates to:
  /// **'Throw the dice: a total of 7 or more hurts the shadow. Land three hits.'**
  String get campaignM4Task;

  /// No description provided for @campaignM4Badge.
  ///
  /// In en, this message translates to:
  /// **'Shadow chaser'**
  String get campaignM4Badge;

  /// No description provided for @campaignM5Title.
  ///
  /// In en, this message translates to:
  /// **'Two stairways'**
  String get campaignM5Title;

  /// No description provided for @campaignM5Story.
  ///
  /// In en, this message translates to:
  /// **'The stairs split in two: one climbs into the cold, the other dives into the cellar. Nobody tells you which is right. Tonight, you decide.'**
  String get campaignM5Story;

  /// No description provided for @campaignM5Lesson.
  ///
  /// In en, this message translates to:
  /// **'In a role-playing game, your choices change the story.'**
  String get campaignM5Lesson;

  /// No description provided for @campaignM5Task.
  ///
  /// In en, this message translates to:
  /// **'Draw a dilemma for inspiration, then choose your way.'**
  String get campaignM5Task;

  /// No description provided for @campaignM5Badge.
  ///
  /// In en, this message translates to:
  /// **'Path chooser'**
  String get campaignM5Badge;

  /// No description provided for @campaignM5ChoiceA.
  ///
  /// In en, this message translates to:
  /// **'Climb the cold stairs'**
  String get campaignM5ChoiceA;

  /// No description provided for @campaignM5ChoiceB.
  ///
  /// In en, this message translates to:
  /// **'Go down to the cellar'**
  String get campaignM5ChoiceB;

  /// No description provided for @campaignM5OutcomeA.
  ///
  /// In en, this message translates to:
  /// **'The cold sharpens your senses and you reach the top without a sound.'**
  String get campaignM5OutcomeA;

  /// No description provided for @campaignM5OutcomeB.
  ///
  /// In en, this message translates to:
  /// **'In the dark, your hands find a forgotten key.'**
  String get campaignM5OutcomeB;

  /// No description provided for @campaignM6Title.
  ///
  /// In en, this message translates to:
  /// **'The lantern relights'**
  String get campaignM6Title;

  /// No description provided for @campaignM6Story.
  ///
  /// In en, this message translates to:
  /// **'At the top, the lantern waits. Describe out loud how you relight it before the sand runs out: telling the scene is the heart of the game.'**
  String get campaignM6Story;

  /// No description provided for @campaignM6Lesson.
  ///
  /// In en, this message translates to:
  /// **'A scene is told together, out loud, with a bit of imagination.'**
  String get campaignM6Lesson;

  /// No description provided for @campaignM6Task.
  ///
  /// In en, this message translates to:
  /// **'Start the hourglass and narrate your final scene.'**
  String get campaignM6Task;

  /// No description provided for @campaignM6Badge.
  ///
  /// In en, this message translates to:
  /// **'Flame bearer'**
  String get campaignM6Badge;

  /// No description provided for @chroniclesTitle.
  ///
  /// In en, this message translates to:
  /// **'Chronicles'**
  String get chroniclesTitle;

  /// No description provided for @chroniclesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Build a character in five steps by opening boosters.'**
  String get chroniclesSubtitle;

  /// No description provided for @chroniclesChooseUniverse.
  ///
  /// In en, this message translates to:
  /// **'Choose a universe'**
  String get chroniclesChooseUniverse;

  /// No description provided for @chroniclesResume.
  ///
  /// In en, this message translates to:
  /// **'Resume my character'**
  String get chroniclesResume;

  /// No description provided for @chroniclesRestart.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get chroniclesRestart;

  /// No description provided for @chroniclesStep.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get chroniclesStep;

  /// No description provided for @chroniclesChooseEdition.
  ///
  /// In en, this message translates to:
  /// **'Choose a booster edition'**
  String get chroniclesChooseEdition;

  /// No description provided for @chroniclesTearBooster.
  ///
  /// In en, this message translates to:
  /// **'Tear the booster'**
  String get chroniclesTearBooster;

  /// No description provided for @chroniclesKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get chroniclesKeep;

  /// No description provided for @chroniclesPass.
  ///
  /// In en, this message translates to:
  /// **'Pass'**
  String get chroniclesPass;

  /// No description provided for @chroniclesFlip.
  ///
  /// In en, this message translates to:
  /// **'Flip the card'**
  String get chroniclesFlip;

  /// No description provided for @chroniclesRefusedQuota.
  ///
  /// In en, this message translates to:
  /// **'No room left for this type of card.'**
  String get chroniclesRefusedQuota;

  /// No description provided for @chroniclesRefusedConflict.
  ///
  /// In en, this message translates to:
  /// **'This card conflicts with a card you kept.'**
  String get chroniclesRefusedConflict;

  /// No description provided for @chroniclesRecap.
  ///
  /// In en, this message translates to:
  /// **'Booster recap'**
  String get chroniclesRecap;

  /// No description provided for @chroniclesNoneKept.
  ///
  /// In en, this message translates to:
  /// **'No card kept from this booster.'**
  String get chroniclesNoneKept;

  /// No description provided for @chroniclesDestiny.
  ///
  /// In en, this message translates to:
  /// **'Let destiny complete'**
  String get chroniclesDestiny;

  /// No description provided for @chroniclesChosenByDestiny.
  ///
  /// In en, this message translates to:
  /// **'Chosen by destiny'**
  String get chroniclesChosenByDestiny;

  /// No description provided for @chroniclesContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get chroniclesContinue;

  /// No description provided for @chroniclesStillMissing.
  ///
  /// In en, this message translates to:
  /// **'Still missing'**
  String get chroniclesStillMissing;

  /// No description provided for @chroniclesSheet.
  ///
  /// In en, this message translates to:
  /// **'Character sheet'**
  String get chroniclesSheet;

  /// No description provided for @chroniclesAbilities.
  ///
  /// In en, this message translates to:
  /// **'Abilities'**
  String get chroniclesAbilities;

  /// No description provided for @chroniclesRarity.
  ///
  /// In en, this message translates to:
  /// **'Rarity'**
  String get chroniclesRarity;

  /// No description provided for @chroniclesCards.
  ///
  /// In en, this message translates to:
  /// **'Kept cards'**
  String get chroniclesCards;

  /// No description provided for @chroniclesCopyText.
  ///
  /// In en, this message translates to:
  /// **'Copy as text'**
  String get chroniclesCopyText;

  /// No description provided for @chroniclesCopyJson.
  ///
  /// In en, this message translates to:
  /// **'Copy as JSON'**
  String get chroniclesCopyJson;

  /// No description provided for @chroniclesShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get chroniclesShare;

  /// No description provided for @chroniclesSaveToLibrary.
  ///
  /// In en, this message translates to:
  /// **'Save to my characters'**
  String get chroniclesSaveToLibrary;

  /// No description provided for @chroniclesSaved.
  ///
  /// In en, this message translates to:
  /// **'Character saved'**
  String get chroniclesSaved;

  /// No description provided for @chroniclesCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get chroniclesCopied;

  /// No description provided for @chroniclesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'The chronicles data could not be read.'**
  String get chroniclesLoadFailed;

  /// No description provided for @chroniclesClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get chroniclesClose;

  /// No description provided for @chroniclesSwipeHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe right to keep, left to pass, tap for details.'**
  String get chroniclesSwipeHint;

  /// No description provided for @chroniclesTearHint.
  ///
  /// In en, this message translates to:
  /// **'Drag sideways to change edition, drag far to tear.'**
  String get chroniclesTearHint;

  /// No description provided for @diceMyDice.
  ///
  /// In en, this message translates to:
  /// **'My dice'**
  String get diceMyDice;

  /// No description provided for @diceLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'My dice'**
  String get diceLibraryTitle;

  /// No description provided for @diceLibraryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No dice yet. Create your first one.'**
  String get diceLibraryEmpty;

  /// No description provided for @diceNew.
  ///
  /// In en, this message translates to:
  /// **'New die'**
  String get diceNew;

  /// No description provided for @diceEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit die'**
  String get diceEdit;

  /// No description provided for @diceDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate die'**
  String get diceDuplicate;

  /// No description provided for @diceDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete die'**
  String get diceDelete;

  /// No description provided for @diceExport.
  ///
  /// In en, this message translates to:
  /// **'Export die'**
  String get diceExport;

  /// No description provided for @diceExportSelection.
  ///
  /// In en, this message translates to:
  /// **'Export selected dice'**
  String get diceExportSelection;

  /// No description provided for @diceImport.
  ///
  /// In en, this message translates to:
  /// **'Import dice'**
  String get diceImport;

  /// No description provided for @diceImported.
  ///
  /// In en, this message translates to:
  /// **'Dice imported.'**
  String get diceImported;

  /// No description provided for @diceImportFailed.
  ///
  /// In en, this message translates to:
  /// **'This dice file is not valid.'**
  String get diceImportFailed;

  /// No description provided for @diceImportClashTitle.
  ///
  /// In en, this message translates to:
  /// **'Dice already in your library'**
  String get diceImportClashTitle;

  /// No description provided for @diceImportClashBody.
  ///
  /// In en, this message translates to:
  /// **'{count} dice already exist. Replace them or keep both?'**
  String diceImportClashBody(Object count);

  /// No description provided for @diceImportReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get diceImportReplace;

  /// No description provided for @diceImportKeepBoth.
  ///
  /// In en, this message translates to:
  /// **'Keep both'**
  String get diceImportKeepBoth;

  /// No description provided for @diceCopyName.
  ///
  /// In en, this message translates to:
  /// **'{name} (copy)'**
  String diceCopyName(Object name);

  /// No description provided for @diceSelectDie.
  ///
  /// In en, this message translates to:
  /// **'Select {name}'**
  String diceSelectDie(Object name);

  /// No description provided for @diceFaceTotal.
  ///
  /// In en, this message translates to:
  /// **'{count} faces'**
  String diceFaceTotal(Object count);

  /// No description provided for @diceManage.
  ///
  /// In en, this message translates to:
  /// **'Manage my dice'**
  String get diceManage;

  /// No description provided for @diceEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'Design a die'**
  String get diceEditorTitle;

  /// No description provided for @diceName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get diceName;

  /// No description provided for @diceFaceCount.
  ///
  /// In en, this message translates to:
  /// **'Number of faces (2 to 100)'**
  String get diceFaceCount;

  /// No description provided for @diceBodyColor.
  ///
  /// In en, this message translates to:
  /// **'Die color'**
  String get diceBodyColor;

  /// No description provided for @diceFaces.
  ///
  /// In en, this message translates to:
  /// **'Faces'**
  String get diceFaces;

  /// No description provided for @diceFaceEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit face {n}'**
  String diceFaceEdit(Object n);

  /// No description provided for @diceFaceText.
  ///
  /// In en, this message translates to:
  /// **'Text or number'**
  String get diceFaceText;

  /// No description provided for @diceFaceIcon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get diceFaceIcon;

  /// No description provided for @diceFaceImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get diceFaceImage;

  /// No description provided for @diceIconSearch.
  ///
  /// In en, this message translates to:
  /// **'Search icons'**
  String get diceIconSearch;

  /// No description provided for @diceImageImport.
  ///
  /// In en, this message translates to:
  /// **'Import image'**
  String get diceImageImport;

  /// No description provided for @diceImageDraw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get diceImageDraw;

  /// No description provided for @diceDrawUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo stroke'**
  String get diceDrawUndo;

  /// No description provided for @diceDrawClear.
  ///
  /// In en, this message translates to:
  /// **'Clear drawing'**
  String get diceDrawClear;

  /// No description provided for @diceDrawWidth.
  ///
  /// In en, this message translates to:
  /// **'Stroke width'**
  String get diceDrawWidth;

  /// No description provided for @diceDrawColor.
  ///
  /// In en, this message translates to:
  /// **'Stroke color'**
  String get diceDrawColor;

  /// No description provided for @diceDrawUse.
  ///
  /// In en, this message translates to:
  /// **'Use this drawing'**
  String get diceDrawUse;

  /// No description provided for @diceBulk.
  ///
  /// In en, this message translates to:
  /// **'Fill several faces'**
  String get diceBulk;

  /// No description provided for @diceBulkFrom.
  ///
  /// In en, this message translates to:
  /// **'From face'**
  String get diceBulkFrom;

  /// No description provided for @diceBulkTo.
  ///
  /// In en, this message translates to:
  /// **'To face'**
  String get diceBulkTo;

  /// No description provided for @diceBulkStart.
  ///
  /// In en, this message translates to:
  /// **'First number'**
  String get diceBulkStart;

  /// No description provided for @diceBulkNumber.
  ///
  /// In en, this message translates to:
  /// **'Number the range'**
  String get diceBulkNumber;

  /// No description provided for @diceBulkCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy face {n} to the range'**
  String diceBulkCopy(Object n);

  /// No description provided for @diceFaceMoveEarlier.
  ///
  /// In en, this message translates to:
  /// **'Move face earlier'**
  String get diceFaceMoveEarlier;

  /// No description provided for @diceFaceMoveLater.
  ///
  /// In en, this message translates to:
  /// **'Move face later'**
  String get diceFaceMoveLater;

  /// No description provided for @diceFaceDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate face'**
  String get diceFaceDuplicate;

  /// No description provided for @diceFaceRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove face'**
  String get diceFaceRemove;

  /// No description provided for @diceUseFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'Use a die from My dice'**
  String get diceUseFromLibrary;

  /// No description provided for @avatarCreatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get avatarCreatorTitle;

  /// No description provided for @avatarEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit appearance'**
  String get avatarEdit;

  /// No description provided for @avatarSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get avatarSave;

  /// No description provided for @avatarNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get avatarNone;

  /// No description provided for @avatarColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get avatarColor;

  /// No description provided for @avatarSlotBase.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get avatarSlotBase;

  /// No description provided for @avatarSlotHead.
  ///
  /// In en, this message translates to:
  /// **'Head'**
  String get avatarSlotHead;

  /// No description provided for @avatarSlotEyes.
  ///
  /// In en, this message translates to:
  /// **'Eyes'**
  String get avatarSlotEyes;

  /// No description provided for @avatarSlotEyebrows.
  ///
  /// In en, this message translates to:
  /// **'Eyebrows'**
  String get avatarSlotEyebrows;

  /// No description provided for @avatarSlotNose.
  ///
  /// In en, this message translates to:
  /// **'Nose'**
  String get avatarSlotNose;

  /// No description provided for @avatarSlotMouth.
  ///
  /// In en, this message translates to:
  /// **'Mouth'**
  String get avatarSlotMouth;

  /// No description provided for @avatarSlotHair.
  ///
  /// In en, this message translates to:
  /// **'Hair'**
  String get avatarSlotHair;

  /// No description provided for @avatarSlotBeard.
  ///
  /// In en, this message translates to:
  /// **'Beard'**
  String get avatarSlotBeard;

  /// No description provided for @avatarSlotMarks.
  ///
  /// In en, this message translates to:
  /// **'Marks'**
  String get avatarSlotMarks;

  /// No description provided for @avatarSlotOutfit.
  ///
  /// In en, this message translates to:
  /// **'Outfit'**
  String get avatarSlotOutfit;

  /// No description provided for @avatarSlotShoes.
  ///
  /// In en, this message translates to:
  /// **'Shoes'**
  String get avatarSlotShoes;

  /// No description provided for @avatarSlotAccessory.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get avatarSlotAccessory;

  /// No description provided for @avatarSlotImplant.
  ///
  /// In en, this message translates to:
  /// **'Implants'**
  String get avatarSlotImplant;

  /// No description provided for @avatarSlotEquipment.
  ///
  /// In en, this message translates to:
  /// **'Gear'**
  String get avatarSlotEquipment;

  /// No description provided for @avatarSlotWeapon.
  ///
  /// In en, this message translates to:
  /// **'Weapons and tools'**
  String get avatarSlotWeapon;

  /// No description provided for @toolMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get toolMapTitle;

  /// No description provided for @toolMapSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pins, tokens and sketches on a board of your choice.'**
  String get toolMapSubtitle;

  /// No description provided for @mapToolMove.
  ///
  /// In en, this message translates to:
  /// **'Move and zoom'**
  String get mapToolMove;

  /// No description provided for @mapToolPin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get mapToolPin;

  /// No description provided for @mapToolToken.
  ///
  /// In en, this message translates to:
  /// **'Token'**
  String get mapToolToken;

  /// No description provided for @mapToolLine.
  ///
  /// In en, this message translates to:
  /// **'Line'**
  String get mapToolLine;

  /// No description provided for @mapToolZone.
  ///
  /// In en, this message translates to:
  /// **'Zone'**
  String get mapToolZone;

  /// No description provided for @mapToolErase.
  ///
  /// In en, this message translates to:
  /// **'Erase'**
  String get mapToolErase;

  /// No description provided for @mapUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get mapUndo;

  /// No description provided for @mapBackground.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get mapBackground;

  /// No description provided for @mapBackgroundBlank.
  ///
  /// In en, this message translates to:
  /// **'Blank'**
  String get mapBackgroundBlank;

  /// No description provided for @mapBackgroundGrid.
  ///
  /// In en, this message translates to:
  /// **'Square grid'**
  String get mapBackgroundGrid;

  /// No description provided for @mapBackgroundHex.
  ///
  /// In en, this message translates to:
  /// **'Hex grid'**
  String get mapBackgroundHex;

  /// No description provided for @mapBackgroundImage.
  ///
  /// In en, this message translates to:
  /// **'Import an image'**
  String get mapBackgroundImage;

  /// No description provided for @mapIcon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get mapIcon;

  /// No description provided for @mapColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get mapColor;

  /// No description provided for @mapMarkerLabel.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get mapMarkerLabel;

  /// No description provided for @mapMarkerDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get mapMarkerDelete;

  /// No description provided for @diceLook.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get diceLook;

  /// No description provided for @diceLookSkin.
  ///
  /// In en, this message translates to:
  /// **'Dice'**
  String get diceLookSkin;

  /// No description provided for @diceLookTable.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get diceLookTable;

  /// No description provided for @diceSkinClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get diceSkinClassic;

  /// No description provided for @diceSkinMatte.
  ///
  /// In en, this message translates to:
  /// **'Matte black'**
  String get diceSkinMatte;

  /// No description provided for @diceSkinGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get diceSkinGold;

  /// No description provided for @diceSkinWood.
  ///
  /// In en, this message translates to:
  /// **'Wood'**
  String get diceSkinWood;

  /// No description provided for @diceSkinCrystal.
  ///
  /// In en, this message translates to:
  /// **'Crystal'**
  String get diceSkinCrystal;

  /// No description provided for @diceSkinGlass.
  ///
  /// In en, this message translates to:
  /// **'Glass'**
  String get diceSkinGlass;

  /// No description provided for @diceTableFelt.
  ///
  /// In en, this message translates to:
  /// **'Felt'**
  String get diceTableFelt;

  /// No description provided for @diceTableDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get diceTableDark;

  /// No description provided for @diceTableLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get diceTableLight;

  /// No description provided for @diceTableWood.
  ///
  /// In en, this message translates to:
  /// **'Wood'**
  String get diceTableWood;

  /// No description provided for @diceTableBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get diceTableBlue;

  /// No description provided for @diceTrayCount.
  ///
  /// In en, this message translates to:
  /// **'{count} dice'**
  String diceTrayCount(int count);

  /// No description provided for @notebookHomeTile.
  ///
  /// In en, this message translates to:
  /// **'Campaign notebook'**
  String get notebookHomeTile;

  /// No description provided for @notebookTitle.
  ///
  /// In en, this message translates to:
  /// **'Campaign notebook'**
  String get notebookTitle;

  /// No description provided for @notebookIntro.
  ///
  /// In en, this message translates to:
  /// **'Keep the story of your solo adventures or your game master notes, with an oracle to answer your questions.'**
  String get notebookIntro;

  /// No description provided for @notebookEmpty.
  ///
  /// In en, this message translates to:
  /// **'No campaign yet'**
  String get notebookEmpty;

  /// No description provided for @notebookEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Create a campaign or import a file to begin.'**
  String get notebookEmptyHint;

  /// No description provided for @notebookNewCampaign.
  ///
  /// In en, this message translates to:
  /// **'New campaign'**
  String get notebookNewCampaign;

  /// No description provided for @notebookCampaignName.
  ///
  /// In en, this message translates to:
  /// **'Campaign name'**
  String get notebookCampaignName;

  /// No description provided for @notebookCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get notebookCreate;

  /// No description provided for @notebookKindSolo.
  ///
  /// In en, this message translates to:
  /// **'Solo'**
  String get notebookKindSolo;

  /// No description provided for @notebookKindGm.
  ///
  /// In en, this message translates to:
  /// **'Game master'**
  String get notebookKindGm;

  /// No description provided for @notebookImport.
  ///
  /// In en, this message translates to:
  /// **'Import a campaign'**
  String get notebookImport;

  /// No description provided for @notebookImported.
  ///
  /// In en, this message translates to:
  /// **'Campaign imported'**
  String get notebookImported;

  /// No description provided for @notebookImportFailed.
  ///
  /// In en, this message translates to:
  /// **'This file is not a campaign'**
  String get notebookImportFailed;

  /// No description provided for @notebookExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get notebookExport;

  /// No description provided for @notebookDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get notebookDelete;

  /// No description provided for @notebookDeleteAsk.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}” and everything in it?'**
  String notebookDeleteAsk(String name);

  /// No description provided for @notebookFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get notebookFavorite;

  /// No description provided for @notebookLook.
  ///
  /// In en, this message translates to:
  /// **'Look'**
  String get notebookLook;

  /// No description provided for @notebookPalette.
  ///
  /// In en, this message translates to:
  /// **'Palette'**
  String get notebookPalette;

  /// No description provided for @notebookDefaultPalette.
  ///
  /// In en, this message translates to:
  /// **'Default palette'**
  String get notebookDefaultPalette;

  /// No description provided for @notebookHeaderImage.
  ///
  /// In en, this message translates to:
  /// **'Header image'**
  String get notebookHeaderImage;

  /// No description provided for @notebookRemoveImage.
  ///
  /// In en, this message translates to:
  /// **'Remove image'**
  String get notebookRemoveImage;

  /// No description provided for @notebookTabJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get notebookTabJournal;

  /// No description provided for @notebookTabEntries.
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get notebookTabEntries;

  /// No description provided for @notebookTabOracle.
  ///
  /// In en, this message translates to:
  /// **'Oracle'**
  String get notebookTabOracle;

  /// No description provided for @notebookStartSession.
  ///
  /// In en, this message translates to:
  /// **'Start a session'**
  String get notebookStartSession;

  /// No description provided for @notebookEndSession.
  ///
  /// In en, this message translates to:
  /// **'End session'**
  String get notebookEndSession;

  /// No description provided for @notebookSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Session title'**
  String get notebookSessionTitle;

  /// No description provided for @notebookSession.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get notebookSession;

  /// No description provided for @notebookSessionActive.
  ///
  /// In en, this message translates to:
  /// **'active'**
  String get notebookSessionActive;

  /// No description provided for @notebookJournalEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing written yet. Tell what happened below.'**
  String get notebookJournalEmpty;

  /// No description provided for @notebookQuickEntryHint.
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get notebookQuickEntryHint;

  /// No description provided for @notebookAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get notebookAdd;

  /// No description provided for @notebookAddToJournal.
  ///
  /// In en, this message translates to:
  /// **'Add to journal'**
  String get notebookAddToJournal;

  /// No description provided for @notebookRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get notebookRemove;

  /// No description provided for @notebookToolDice.
  ///
  /// In en, this message translates to:
  /// **'Dice'**
  String get notebookToolDice;

  /// No description provided for @notebookToolOracle.
  ///
  /// In en, this message translates to:
  /// **'Oracle'**
  String get notebookToolOracle;

  /// No description provided for @notebookToolGenerator.
  ///
  /// In en, this message translates to:
  /// **'Generator'**
  String get notebookToolGenerator;

  /// No description provided for @notebookToolScene.
  ///
  /// In en, this message translates to:
  /// **'Scene note'**
  String get notebookToolScene;

  /// No description provided for @notebookSceneNote.
  ///
  /// In en, this message translates to:
  /// **'Scene'**
  String get notebookSceneNote;

  /// No description provided for @notebookDiceExpression.
  ///
  /// In en, this message translates to:
  /// **'Roll (for example 2d6+1)'**
  String get notebookDiceExpression;

  /// No description provided for @notebookDiceInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use a format like 2d6+1'**
  String get notebookDiceInvalid;

  /// No description provided for @notebookRoll.
  ///
  /// In en, this message translates to:
  /// **'Roll'**
  String get notebookRoll;

  /// No description provided for @notebookReroll.
  ///
  /// In en, this message translates to:
  /// **'Draw again'**
  String get notebookReroll;

  /// No description provided for @notebookAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notebookAll;

  /// No description provided for @notebookKindNpc.
  ///
  /// In en, this message translates to:
  /// **'Character'**
  String get notebookKindNpc;

  /// No description provided for @notebookKindPlace.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get notebookKindPlace;

  /// No description provided for @notebookKindQuest.
  ///
  /// In en, this message translates to:
  /// **'Quest'**
  String get notebookKindQuest;

  /// No description provided for @notebookKindLoot.
  ///
  /// In en, this message translates to:
  /// **'Loot'**
  String get notebookKindLoot;

  /// No description provided for @notebookKindFaction.
  ///
  /// In en, this message translates to:
  /// **'Faction'**
  String get notebookKindFaction;

  /// No description provided for @notebookNewEntry.
  ///
  /// In en, this message translates to:
  /// **'New entry'**
  String get notebookNewEntry;

  /// No description provided for @notebookEntryName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get notebookEntryName;

  /// No description provided for @notebookEntriesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No entry yet. Add characters, places, quests, loot and factions.'**
  String get notebookEntriesEmpty;

  /// No description provided for @notebookSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search the campaign'**
  String get notebookSearchHint;

  /// No description provided for @notebookNoResults.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get notebookNoResults;

  /// No description provided for @notebookSectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get notebookSectionDescription;

  /// No description provided for @notebookSectionNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notebookSectionNotes;

  /// No description provided for @notebookSectionChecklist.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get notebookSectionChecklist;

  /// No description provided for @notebookSectionTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get notebookSectionTags;

  /// No description provided for @notebookSectionStats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get notebookSectionStats;

  /// No description provided for @notebookSectionPictures.
  ///
  /// In en, this message translates to:
  /// **'Pictures'**
  String get notebookSectionPictures;

  /// No description provided for @notebookAddSection.
  ///
  /// In en, this message translates to:
  /// **'Add a section'**
  String get notebookAddSection;

  /// No description provided for @notebookSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename section'**
  String get notebookSectionTitle;

  /// No description provided for @notebookAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add an item'**
  String get notebookAddItem;

  /// No description provided for @notebookAddTag.
  ///
  /// In en, this message translates to:
  /// **'Add a tag'**
  String get notebookAddTag;

  /// No description provided for @notebookStatName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get notebookStatName;

  /// No description provided for @notebookStatValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get notebookStatValue;

  /// No description provided for @notebookAddStat.
  ///
  /// In en, this message translates to:
  /// **'Add a statistic'**
  String get notebookAddStat;

  /// No description provided for @notebookAddPicture.
  ///
  /// In en, this message translates to:
  /// **'Add a picture'**
  String get notebookAddPicture;

  /// No description provided for @notebookLinkHint.
  ///
  /// In en, this message translates to:
  /// **'Write here. Names of other entries become links, or use [[Name]].'**
  String get notebookLinkHint;

  /// No description provided for @notebookBacklinks.
  ///
  /// In en, this message translates to:
  /// **'Mentioned in'**
  String get notebookBacklinks;

  /// No description provided for @notebookLikelihood.
  ///
  /// In en, this message translates to:
  /// **'Likelihood'**
  String get notebookLikelihood;

  /// No description provided for @notebookLikelihoodVeryUnlikely.
  ///
  /// In en, this message translates to:
  /// **'Very unlikely'**
  String get notebookLikelihoodVeryUnlikely;

  /// No description provided for @notebookLikelihoodUnlikely.
  ///
  /// In en, this message translates to:
  /// **'Unlikely'**
  String get notebookLikelihoodUnlikely;

  /// No description provided for @notebookLikelihoodEven.
  ///
  /// In en, this message translates to:
  /// **'Even odds'**
  String get notebookLikelihoodEven;

  /// No description provided for @notebookLikelihoodLikely.
  ///
  /// In en, this message translates to:
  /// **'Likely'**
  String get notebookLikelihoodLikely;

  /// No description provided for @notebookLikelihoodVeryLikely.
  ///
  /// In en, this message translates to:
  /// **'Very likely'**
  String get notebookLikelihoodVeryLikely;

  /// No description provided for @notebookChaos.
  ///
  /// In en, this message translates to:
  /// **'Chaos factor: {value}'**
  String notebookChaos(int value);

  /// No description provided for @notebookAsk.
  ///
  /// In en, this message translates to:
  /// **'Ask the oracle'**
  String get notebookAsk;

  /// No description provided for @notebookOracleQuestion.
  ///
  /// In en, this message translates to:
  /// **'Yes or no question'**
  String get notebookOracleQuestion;

  /// No description provided for @notebookAnswerYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get notebookAnswerYes;

  /// No description provided for @notebookAnswerNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get notebookAnswerNo;

  /// No description provided for @notebookAnswerExceptionalYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, and more'**
  String get notebookAnswerExceptionalYes;

  /// No description provided for @notebookAnswerExceptionalNo.
  ///
  /// In en, this message translates to:
  /// **'No, and worse'**
  String get notebookAnswerExceptionalNo;

  /// No description provided for @notebookAnswerEvent.
  ///
  /// In en, this message translates to:
  /// **'a random event occurs'**
  String get notebookAnswerEvent;

  /// No description provided for @notebookSceneCheck.
  ///
  /// In en, this message translates to:
  /// **'Scene check'**
  String get notebookSceneCheck;

  /// No description provided for @notebookSceneExpected.
  ///
  /// In en, this message translates to:
  /// **'The scene goes as expected'**
  String get notebookSceneExpected;

  /// No description provided for @notebookSceneAltered.
  ///
  /// In en, this message translates to:
  /// **'The scene is altered'**
  String get notebookSceneAltered;

  /// No description provided for @notebookSceneInterrupted.
  ///
  /// In en, this message translates to:
  /// **'The scene is interrupted'**
  String get notebookSceneInterrupted;

  /// No description provided for @notebookMeaning.
  ///
  /// In en, this message translates to:
  /// **'Action and theme'**
  String get notebookMeaning;

  /// No description provided for @notebookDescriptors.
  ///
  /// In en, this message translates to:
  /// **'Descriptors'**
  String get notebookDescriptors;

  /// No description provided for @notebookRandomEvent.
  ///
  /// In en, this message translates to:
  /// **'Random event'**
  String get notebookRandomEvent;

  /// No description provided for @notebookReaction.
  ///
  /// In en, this message translates to:
  /// **'NPC reaction'**
  String get notebookReaction;

  /// No description provided for @notebookDiscovery.
  ///
  /// In en, this message translates to:
  /// **'Discovery'**
  String get notebookDiscovery;

  /// No description provided for @notebookComplication.
  ///
  /// In en, this message translates to:
  /// **'Complication'**
  String get notebookComplication;

  /// No description provided for @notebookTabAtlas.
  ///
  /// In en, this message translates to:
  /// **'Atlas'**
  String get notebookTabAtlas;

  /// No description provided for @notebookAtlasEmpty.
  ///
  /// In en, this message translates to:
  /// **'No place yet. Add a sea, an isle, then a settlement or a dungeon inside it.'**
  String get notebookAtlasEmpty;

  /// No description provided for @notebookNewPlace.
  ///
  /// In en, this message translates to:
  /// **'New place'**
  String get notebookNewPlace;

  /// No description provided for @notebookOpenMap.
  ///
  /// In en, this message translates to:
  /// **'Open the map'**
  String get notebookOpenMap;

  /// No description provided for @notebookParentPlace.
  ///
  /// In en, this message translates to:
  /// **'Inside'**
  String get notebookParentPlace;

  /// No description provided for @notebookNoParent.
  ///
  /// In en, this message translates to:
  /// **'Nothing (top level)'**
  String get notebookNoParent;

  /// No description provided for @notebookPins.
  ///
  /// In en, this message translates to:
  /// **'Pins'**
  String get notebookPins;

  /// No description provided for @notebookNoPins.
  ///
  /// In en, this message translates to:
  /// **'Place a pin on the map to link it to an entry or another map.'**
  String get notebookNoPins;

  /// No description provided for @notebookPinLink.
  ///
  /// In en, this message translates to:
  /// **'Link to'**
  String get notebookPinLink;

  /// No description provided for @notebookPinUnlinked.
  ///
  /// In en, this message translates to:
  /// **'Not linked'**
  String get notebookPinUnlinked;

  /// No description provided for @notebookPinUnnamed.
  ///
  /// In en, this message translates to:
  /// **'Unnamed pin'**
  String get notebookPinUnnamed;

  /// No description provided for @notebookSearchAll.
  ///
  /// In en, this message translates to:
  /// **'Search all campaigns'**
  String get notebookSearchAll;

  /// No description provided for @sheetFieldName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get sheetFieldName;

  /// No description provided for @sheetFieldNickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get sheetFieldNickname;

  /// No description provided for @sheetFieldAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get sheetFieldAge;

  /// No description provided for @sheetFieldBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get sheetFieldBirthDate;

  /// No description provided for @sheetFieldBirthPlace.
  ///
  /// In en, this message translates to:
  /// **'Place of birth'**
  String get sheetFieldBirthPlace;

  /// No description provided for @sheetFieldGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get sheetFieldGender;

  /// No description provided for @sheetFieldOrigin.
  ///
  /// In en, this message translates to:
  /// **'Nationality and origins'**
  String get sheetFieldOrigin;

  /// No description provided for @sheetFieldLanguages.
  ///
  /// In en, this message translates to:
  /// **'Languages spoken'**
  String get sheetFieldLanguages;

  /// No description provided for @sheetFieldJob.
  ///
  /// In en, this message translates to:
  /// **'Trade or occupation'**
  String get sheetFieldJob;

  /// No description provided for @sheetFieldStatus.
  ///
  /// In en, this message translates to:
  /// **'Social status'**
  String get sheetFieldStatus;

  /// No description provided for @sheetFieldGroup.
  ///
  /// In en, this message translates to:
  /// **'Group (family, clan...)'**
  String get sheetFieldGroup;

  /// No description provided for @sheetFieldSkin.
  ///
  /// In en, this message translates to:
  /// **'Skin color'**
  String get sheetFieldSkin;

  /// No description provided for @sheetFieldEyes.
  ///
  /// In en, this message translates to:
  /// **'Eye color'**
  String get sheetFieldEyes;

  /// No description provided for @sheetFieldHair.
  ///
  /// In en, this message translates to:
  /// **'Hair color'**
  String get sheetFieldHair;

  /// No description provided for @sheetFieldBuild.
  ///
  /// In en, this message translates to:
  /// **'Build'**
  String get sheetFieldBuild;

  /// No description provided for @sheetFieldHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get sheetFieldHeight;

  /// No description provided for @sheetFieldStyle.
  ///
  /// In en, this message translates to:
  /// **'Clothing style'**
  String get sheetFieldStyle;

  /// No description provided for @sheetFieldMarks.
  ///
  /// In en, this message translates to:
  /// **'Distinctive marks'**
  String get sheetFieldMarks;

  /// No description provided for @sheetFieldQualities.
  ///
  /// In en, this message translates to:
  /// **'Qualities'**
  String get sheetFieldQualities;

  /// No description provided for @sheetFieldFlaws.
  ///
  /// In en, this message translates to:
  /// **'Flaws'**
  String get sheetFieldFlaws;

  /// No description provided for @sheetFieldLikes.
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get sheetFieldLikes;

  /// No description provided for @sheetFieldDislikes.
  ///
  /// In en, this message translates to:
  /// **'Dislikes'**
  String get sheetFieldDislikes;

  /// No description provided for @sheetFieldTalents.
  ///
  /// In en, this message translates to:
  /// **'Special talents'**
  String get sheetFieldTalents;

  /// No description provided for @sheetFieldHabits.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get sheetFieldHabits;

  /// No description provided for @sheetFieldMotivation.
  ///
  /// In en, this message translates to:
  /// **'Deep motivation'**
  String get sheetFieldMotivation;

  /// No description provided for @sheetFieldGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal in the story'**
  String get sheetFieldGoal;

  /// No description provided for @sheetFieldFamily.
  ///
  /// In en, this message translates to:
  /// **'Family origin'**
  String get sheetFieldFamily;

  /// No description provided for @sheetFieldChildhood.
  ///
  /// In en, this message translates to:
  /// **'Childhood story and trauma'**
  String get sheetFieldChildhood;

  /// No description provided for @sheetFieldExperiences.
  ///
  /// In en, this message translates to:
  /// **'Experiences useful to the story'**
  String get sheetFieldExperiences;

  /// No description provided for @sheetFieldEvolution.
  ///
  /// In en, this message translates to:
  /// **'Evolution before the story'**
  String get sheetFieldEvolution;

  /// No description provided for @sheetFieldSituation.
  ///
  /// In en, this message translates to:
  /// **'Starting situation'**
  String get sheetFieldSituation;

  /// No description provided for @sheetFieldAims.
  ///
  /// In en, this message translates to:
  /// **'Motivations, goals and actions'**
  String get sheetFieldAims;

  /// No description provided for @sheetStep1.
  ///
  /// In en, this message translates to:
  /// **'General information'**
  String get sheetStep1;

  /// No description provided for @sheetStep2.
  ///
  /// In en, this message translates to:
  /// **'Physical appearance'**
  String get sheetStep2;

  /// No description provided for @sheetStep3.
  ///
  /// In en, this message translates to:
  /// **'Personality and abilities'**
  String get sheetStep3;

  /// No description provided for @sheetStep4.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get sheetStep4;

  /// No description provided for @sheetStep5.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get sheetStep5;

  /// No description provided for @sheetUniverseFantasy.
  ///
  /// In en, this message translates to:
  /// **'Medieval fantasy'**
  String get sheetUniverseFantasy;

  /// No description provided for @sheetUniverseScifi.
  ///
  /// In en, this message translates to:
  /// **'Science fiction'**
  String get sheetUniverseScifi;

  /// No description provided for @sheetUniverseCyberpunk.
  ///
  /// In en, this message translates to:
  /// **'Cyberpunk'**
  String get sheetUniverseCyberpunk;

  /// No description provided for @sheetUniverseGothique.
  ///
  /// In en, this message translates to:
  /// **'Gothic horror'**
  String get sheetUniverseGothique;

  /// No description provided for @sheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Character sheet'**
  String get sheetTitle;

  /// No description provided for @sheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Five steps, from identity to the first scene.'**
  String get sheetSubtitle;

  /// No description provided for @sheetChooseUniverse.
  ///
  /// In en, this message translates to:
  /// **'Choose a universe'**
  String get sheetChooseUniverse;

  /// No description provided for @sheetOpen.
  ///
  /// In en, this message translates to:
  /// **'Full character sheet'**
  String get sheetOpen;

  /// No description provided for @sheetCompleteFromCards.
  ///
  /// In en, this message translates to:
  /// **'Complete the full sheet'**
  String get sheetCompleteFromCards;

  /// No description provided for @sheetStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String sheetStepOf(int step, int total);

  /// No description provided for @sheetGenerateStep.
  ///
  /// In en, this message translates to:
  /// **'Generate this step'**
  String get sheetGenerateStep;

  /// No description provided for @sheetGenerateAll.
  ///
  /// In en, this message translates to:
  /// **'Generate everything'**
  String get sheetGenerateAll;

  /// No description provided for @sheetPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get sheetPrevious;

  /// No description provided for @sheetNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get sheetNext;

  /// No description provided for @sheetReroll.
  ///
  /// In en, this message translates to:
  /// **'Draw again'**
  String get sheetReroll;

  /// No description provided for @sheetLock.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get sheetLock;

  /// No description provided for @sheetUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get sheetUnlock;

  /// No description provided for @sheetEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get sheetEdit;

  /// No description provided for @sheetEditHint.
  ///
  /// In en, this message translates to:
  /// **'One value per line'**
  String get sheetEditHint;

  /// No description provided for @sheetEditInvalid.
  ///
  /// In en, this message translates to:
  /// **'{min} to {max} values expected'**
  String sheetEditInvalid(int min, int max);

  /// No description provided for @sheetEmpty.
  ///
  /// In en, this message translates to:
  /// **'Not filled in'**
  String get sheetEmpty;

  /// No description provided for @sheetEditMode.
  ///
  /// In en, this message translates to:
  /// **'Edit the sheet'**
  String get sheetEditMode;

  /// No description provided for @sheetReadMode.
  ///
  /// In en, this message translates to:
  /// **'Read the sheet'**
  String get sheetReadMode;

  /// No description provided for @sheetSave.
  ///
  /// In en, this message translates to:
  /// **'Save to my characters'**
  String get sheetSave;

  /// No description provided for @sheetSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get sheetSaved;

  /// No description provided for @sheetCopyText.
  ///
  /// In en, this message translates to:
  /// **'Copy as text'**
  String get sheetCopyText;

  /// No description provided for @sheetCopyJson.
  ///
  /// In en, this message translates to:
  /// **'Copy as JSON'**
  String get sheetCopyJson;

  /// No description provided for @sheetShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get sheetShare;

  /// No description provided for @sheetCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get sheetCopied;

  /// No description provided for @sheetMismatch.
  ///
  /// In en, this message translates to:
  /// **'Some details do not match'**
  String get sheetMismatch;

  /// No description provided for @sheetLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'The sheet tables could not be loaded.'**
  String get sheetLoadFailed;

  /// No description provided for @sheetView.
  ///
  /// In en, this message translates to:
  /// **'View the sheet'**
  String get sheetView;

  /// No description provided for @sheetEditionLabel.
  ///
  /// In en, this message translates to:
  /// **'Edition'**
  String get sheetEditionLabel;

  /// No description provided for @sheetEditionFer.
  ///
  /// In en, this message translates to:
  /// **'Iron'**
  String get sheetEditionFer;

  /// No description provided for @sheetEditionVent.
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get sheetEditionVent;

  /// No description provided for @sheetEditionEsprit.
  ///
  /// In en, this message translates to:
  /// **'Mind'**
  String get sheetEditionEsprit;

  /// No description provided for @sheetApplyAvatar.
  ///
  /// In en, this message translates to:
  /// **'Apply to avatar'**
  String get sheetApplyAvatar;

  /// No description provided for @appearanceSkinCleanName.
  ///
  /// In en, this message translates to:
  /// **'Clean'**
  String get appearanceSkinCleanName;

  /// No description provided for @appearanceSkinCleanDesc.
  ///
  /// In en, this message translates to:
  /// **'Light and dark, quiet surfaces, one blue accent.'**
  String get appearanceSkinCleanDesc;

  /// No description provided for @appearanceFontSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get appearanceFontSystem;

  /// No description provided for @toolShelfPinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get toolShelfPinned;

  /// No description provided for @toolShelfTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get toolShelfTime;

  /// No description provided for @toolShelfChance.
  ///
  /// In en, this message translates to:
  /// **'Dice & chance'**
  String get toolShelfChance;

  /// No description provided for @toolShelfScores.
  ///
  /// In en, this message translates to:
  /// **'Scores & counters'**
  String get toolShelfScores;

  /// No description provided for @toolShelfCards.
  ///
  /// In en, this message translates to:
  /// **'Cards & draw'**
  String get toolShelfCards;

  /// No description provided for @toolShelfMap.
  ///
  /// In en, this message translates to:
  /// **'Map & board'**
  String get toolShelfMap;

  /// No description provided for @toolShelfPlayers.
  ///
  /// In en, this message translates to:
  /// **'Players & turns'**
  String get toolShelfPlayers;

  /// No description provided for @toolShelfStory.
  ///
  /// In en, this message translates to:
  /// **'Story'**
  String get toolShelfStory;

  /// No description provided for @toolShelfGenerators.
  ///
  /// In en, this message translates to:
  /// **'Generators'**
  String get toolShelfGenerators;

  /// No description provided for @toolShelfCharacters.
  ///
  /// In en, this message translates to:
  /// **'Characters'**
  String get toolShelfCharacters;

  /// No description provided for @toolHeroResume.
  ///
  /// In en, this message translates to:
  /// **'Pick up where you left off'**
  String get toolHeroResume;

  /// No description provided for @toolHeroFeatured.
  ///
  /// In en, this message translates to:
  /// **'Featured tool'**
  String get toolHeroFeatured;

  /// No description provided for @toolMoveEarlier.
  ///
  /// In en, this message translates to:
  /// **'Move earlier'**
  String get toolMoveEarlier;

  /// No description provided for @toolMoveLater.
  ///
  /// In en, this message translates to:
  /// **'Move later'**
  String get toolMoveLater;

  /// No description provided for @toolStopwatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Stopwatch'**
  String get toolStopwatchTitle;

  /// No description provided for @toolStopwatchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Count up to the hundredth and mark every lap.'**
  String get toolStopwatchSubtitle;

  /// No description provided for @stopwatchLap.
  ///
  /// In en, this message translates to:
  /// **'Lap'**
  String get stopwatchLap;

  /// No description provided for @stopwatchLapNumber.
  ///
  /// In en, this message translates to:
  /// **'Lap {number}'**
  String stopwatchLapNumber(int number);

  /// No description provided for @toolChessClockTitle.
  ///
  /// In en, this message translates to:
  /// **'Chess clock'**
  String get toolChessClockTitle;

  /// No description provided for @toolChessClockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Two clocks, one tap to pass the turn, with increment.'**
  String get toolChessClockSubtitle;
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
