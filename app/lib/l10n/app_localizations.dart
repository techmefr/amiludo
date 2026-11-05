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
