import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/passy_cloud.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

import 'common.dart';
import 'cloud_register_screen.dart';
import 'cloud_reset_password_screen.dart';
import 'cloud_update_email_screen.dart';
import 'cloud_user_agreement_screen.dart';
import 'log_screen.dart';

class CloudManageScreen extends StatefulWidget {
  static const routeName = '/main/cloudManage';

  const CloudManageScreen({Key? key}) : super(key: key);

  @override
  State<CloudManageScreen> createState() => _CloudManageScreenState();
}

class _CloudManageScreenState extends State<CloudManageScreen> {
  final _account = data.loadedAccount!;
  bool _initialized = false;
  String _status = 'ok';
  bool _plansExpanded = true;
  bool _logsExpanded = false;
  bool _errorDisplayed = false;

  List<Subscription> _subscriptions = [];
  List<Plan> _plans = [];

  Future<void> _checkStatus() async {
    String? token = _account.cloudToken;
    if (token == null) {
      try {
        final resp =
            await PassyCloud.refresh(refreshToken: _account.cloudRefreshToken!);
        _account.cloudToken = resp.token;
        _account.cloudRefreshToken = resp.refresh;
        await _account.saveSettings();
      } catch (e, s) {
        if (e is PassyCloudError) {
          if (e.statusCode == HttpStatus.unauthorized) {
            setState(() => _account.cloudEnabled = false);
            await _account.saveSettings();
            Navigator.pushReplacementNamed(
                context, CloudRegisterScreen.routeName);
            return;
          }
          if (e.error == 'account_not_verified') {
            setState(() => _status = 'not_verified');
            Navigator.pushReplacementNamed(
                context, CloudRegisterScreen.routeName);
            return;
          }
          if (e.error == 'account_locked') {
            setState(() => _status = 'locked');
            return;
          }
        }
        showSnackBar(
          message: localizations.cloudError,
          icon: const Icon(Icons.cloud_off_rounded),
          action: SnackBarAction(
            label: localizations.details,
            onPressed: () => Navigator.pushNamed(context, LogScreen.routeName,
                arguments: e.toString() + '\n' + s.toString()),
          ),
        );
        return;
      }
    }
    setState(() {
      _status = 'ok';
    });
  }

  Future<void> _plansLoop() async {
    if (!mounted) return;
    if (_account.cloudToken == null) {
      Future.delayed(const Duration(seconds: 4), _plansLoop);
      return;
    }
    try {
      final subscriptions =
          (await PassyCloud.subscriptionStatus(token: _account.cloudToken!))
              .subscriptions
              .values
              .toList();
      final plans = (await PassyCloud.getPlans()).plans;
      List<Plan> passyPlans = [];
      if (!subscriptions
          .any((s) => s.service == 'passy' && s.plan == 'lifetime')) {
        for (final plan in plans) {
          if (plan.service != 'passy') continue;
          if (plan.plan == 'monthly') {
            if (subscriptions
                .any((s) => s.service == 'passy' && s.plan == 'yearly')) {
              continue;
            }
          }
          passyPlans.add(plan);
        }
      }
      if (passyPlans.length < plans.length) {
      } else {}
      setState(() {
        _subscriptions = subscriptions;
        _plans = passyPlans;
      });
    } catch (e, s) {
      if (_errorDisplayed) return;
      _errorDisplayed = true;
      showSnackBar(
        message: localizations.cloudError,
        icon: const Icon(Icons.cloud_off_rounded),
        action: SnackBarAction(
          label: localizations.details,
          onPressed: () => Navigator.pushNamed(context, LogScreen.routeName,
              arguments: e.toString() + '\n' + s.toString()),
        ),
      );
    } finally {
      Future.delayed(const Duration(seconds: 4), _plansLoop);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      _initialized = true;
      _checkStatus();
      _plansLoop();
    }
    Map<String, Widget> planWidgets = {
      for (final plan in _plans)
        plan.plan: Column(children: [
          if (plan.plan == 'yearly')
            Padding(
                padding: EdgeInsets.only(
                    top: PassyTheme.of(context).passyPadding.top),
                child: Text(localizations.bestValue,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: PassyTheme.of(context)
                            .highlightContentSecondaryColor))),
          Padding(
              padding: EdgeInsets.only(
                  bottom: PassyTheme.of(context).passyPadding.top,
                  top: plan.plan == 'yearly'
                      ? 0
                      : PassyTheme.of(context).passyPadding.top),
              child: PlanCard(
                  plan: plan,
                  highlight: plan.plan == 'yearly' ? true : false,
                  subscribed: _subscriptions.any(
                      (s) => s.service == plan.service && s.plan == plan.plan),
                  canceled: _subscriptions.any((s) =>
                      s.service == plan.service &&
                      s.plan == plan.plan &&
                      s.cancelAtPeriodEnd),
                  onCancel: () async {
                    final subs = _subscriptions
                        .where((s) =>
                            s.service == plan.service && s.plan == plan.plan)
                        .toList();
                    String? token = _account.cloudToken;
                    if (token == null || subs.isEmpty) {
                      showSnackBar(
                          message: localizations.cloudError,
                          icon: const Icon(Icons.cloud_off_rounded));
                      return;
                    }
                    bool? shouldCancel = await showDialog<bool?>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(localizations.cancelPlan),
                        content:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          Text(localizations.thankYouForUsingPassy),
                          Text(localizations.noRefundsWillBeIssued,
                              style: TextStyle(
                                  color: PassyTheme.of(context)
                                      .highlightContentSecondaryColor)),
                        ]),
                        actions: [
                          TextButton(
                            child: Text(localizations.returnBack),
                            onPressed: () => Navigator.pop(context, false),
                          ),
                          TextButton(
                            child: Text(localizations.confirm),
                            onPressed: () => Navigator.pop(context, true),
                          ),
                        ],
                      ),
                    );
                    if (shouldCancel != true) return;
                    try {
                      await PassyCloud.cancelSubscription(
                          token: token, service: subs[0].service);
                      await _checkStatus();
                    } catch (e, s) {
                      showSnackBar(
                        message: localizations.cloudError,
                        icon: const Icon(Icons.cloud_off_rounded),
                        action: SnackBarAction(
                          label: localizations.details,
                          onPressed: () => Navigator.pushNamed(
                              context, LogScreen.routeName,
                              arguments: e.toString() + '\n' + s.toString()),
                        ),
                      );
                    }
                  },
                  onSelect: () async {
                    final result = await Navigator.pushNamed(
                        context, CloudUserAgreementScreen.routeName);
                    if (result is! bool) return;
                    if (!result) return;
                    try {
                      final token = _account.cloudToken;
                      if (token == null) {
                        showSnackBar(
                            message: localizations.cloudError,
                            icon: const Icon(Icons.cloud_off_rounded));
                        return;
                      }
                      openUrl((await PassyCloud.subscribe(
                              token: token,
                              plan: parseSubscriptionPlan(plan.plan)!))
                          .url);
                    } catch (e, s) {
                      showSnackBar(
                        message: localizations.cloudError,
                        icon: const Icon(Icons.cloud_off_rounded),
                        action: SnackBarAction(
                          label: localizations.details,
                          onPressed: () => Navigator.pushNamed(
                              context, LogScreen.routeName,
                              arguments: e.toString() + '\n' + s.toString()),
                        ),
                      );
                    }
                  }))
        ]),
    };

    return Scaffold(
        appBar: AppBar(
          backgroundColor: PassyTheme.of(context).contentColor,
          leading: PassyPadding(FloatingActionButton(
            heroTag: 'cloudButton',
            child: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          )),
          leadingWidth: 90,
          title: const Text('Passy Cloud'),
          centerTitle: true,
        ),
        body: ListView(children: [
          if (_status == 'not_verified')
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const PassyPadding(Icon(
                  Icons.warning_rounded,
                  color: Colors.yellow,
                )),
                PassyPadding(Text(localizations.accountNotVerified)),
              ],
            ),
          if (_status == 'locked')
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const PassyPadding(Icon(
                  Icons.lock_rounded,
                  color: Colors.red,
                )),
                PassyPadding(Text(localizations.accountLocked)),
              ],
            ),
          if (_status == 'ok')
            PassyPadding(
                SvgPicture.asset('assets/images/passy_cloud.svg', height: 200)),
          if (_status == 'ok' && _subscriptions.isNotEmpty)
            Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _subscriptions.isEmpty
                      ? [
                          PassyPadding(Text(localizations.selectYourPlan,
                              style: const TextStyle(fontSize: 24)))
                        ]
                      : [
                          const PassyPadding(Icon(Icons.sync_rounded)),
                          PassyPadding(Text(localizations.youreAllSet,
                              style: const TextStyle(fontSize: 24))),
                          const PassyPadding(Icon(Icons.sync_rounded)),
                        ],
                )),
          PassyPadding(ExpansionPanelList(
              expandedHeaderPadding: EdgeInsets.zero,
              expansionCallback: (panelIndex, isExpanded) =>
                  setState(() => _plansExpanded = isExpanded),
              elevation: 0,
              dividerColor:
                  PassyTheme.of(context).highlightContentSecondaryColor,
              children: [
                ExpansionPanel(
                    backgroundColor: PassyTheme.of(context).contentColor,
                    isExpanded: _plansExpanded,
                    canTapOnHeader: true,
                    headerBuilder: (context, isExpanded) {
                      return Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(32.0)),
                              color: PassyTheme.of(context)
                                  .highlightContentSecondaryColor),
                          child: PassyPadding(Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Icon(Icons.calendar_month_rounded,
                                    color: PassyTheme.of(context)
                                        .highlightContentTextColor),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Text(
                                    localizations.plans,
                                    style: TextStyle(
                                        color: PassyTheme.of(context)
                                            .highlightContentTextColor),
                                  )),
                            ],
                          )));
                    },
                    body: Column(
                        children: _subscriptions.any((s) =>
                                s.service == 'passy' && s.plan == 'lifetime')
                            ? [
                                PassyPadding(Text('∞  ' +
                                    localizations.youHaveLifetimeAccess +
                                    '  ∞'))
                              ]
                            : [
                                if (_status == 'ok' && _subscriptions.isEmpty)
                                  Padding(
                                      padding: EdgeInsets.only(
                                          top: PassyTheme.of(context)
                                              .passyPadding
                                              .top),
                                      child: Center(
                                          child: Text(
                                              localizations.selectYourPlan,
                                              style: const TextStyle(
                                                  fontSize: 24)))),
                                if (_status == 'ok' && _subscriptions.isEmpty)
                                  Padding(
                                      padding: EdgeInsets.only(
                                          bottom: PassyTheme.of(context)
                                              .passyPadding
                                              .bottom),
                                      child: Center(
                                          child: Text(
                                              '* ' + localizations.noRefunds,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontStyle:
                                                      FontStyle.italic)))),
                                if (_status == 'ok' && planWidgets.isNotEmpty)
                                  Wrap(
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.end,
                                      children: [
                                        for (final plan in planWidgets.entries)
                                          plan.value,
                                      ]),
                              ])),
              ])),
          PassyPadding(ExpansionPanelList(
              expandedHeaderPadding: EdgeInsets.zero,
              expansionCallback: (panelIndex, isExpanded) =>
                  setState(() => _logsExpanded = isExpanded),
              elevation: 0,
              dividerColor:
                  PassyTheme.of(context).highlightContentSecondaryColor,
              children: [
                ExpansionPanel(
                    backgroundColor: PassyTheme.of(context).contentColor,
                    isExpanded: _logsExpanded,
                    canTapOnHeader: true,
                    headerBuilder: (context, isExpanded) {
                      return Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(32.0)),
                              color: PassyTheme.of(context)
                                  .highlightContentSecondaryColor),
                          child: PassyPadding(Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Icon(Icons.notes_rounded,
                                    color: PassyTheme.of(context)
                                        .highlightContentTextColor),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Text(
                                      style: TextStyle(
                                          color: PassyTheme.of(context)
                                              .highlightContentTextColor),
                                      localizations.logs)),
                            ],
                          )));
                    },
                    body: Column(
                      children: [
                        if (PassyCloud.recentErrors.isEmpty)
                          PassyPadding(Text(localizations.noEntries)),
                        for (final error in PassyCloud.recentErrors.reversed)
                          Padding(
                              padding: EdgeInsets.only(
                                  top: PassyTheme.of(context).passyPadding.top),
                              child: TextButton(
                                child: PassyPadding(
                                    Text(error.message.replaceAll('\n', ''))),
                                onPressed: () => Navigator.pushNamed(
                                    context, LogScreen.routeName,
                                    arguments: error.toString()),
                              )),
                      ],
                    )),
              ])),
          if (_account.cloudToken != null)
            PassyPadding(ThreeWidgetButton(
                center: Text(localizations.updateEmailAddress),
                left: const Padding(
                  padding: EdgeInsets.only(right: 30),
                  child: Icon(Icons.email_rounded),
                ),
                right: const Icon(Icons.arrow_forward_ios_rounded),
                onPressed: () {
                  final password = _account.getPassword('gw_cloud');
                  if (password == null) return;
                  Navigator.pushNamed(context, CloudUpdateEmailScreen.routeName,
                      arguments:
                          CloudUpdateEmailScreenArgs(oldEmail: password.email));
                })),
          if (_account.cloudToken != null)
            PassyPadding(ThreeWidgetButton(
                center: Text(localizations.resetPassword),
                left: const Padding(
                  padding: EdgeInsets.only(right: 30),
                  child: Icon(Icons.lock_reset_rounded),
                ),
                right: const Icon(Icons.arrow_forward_ios_rounded),
                onPressed: () {
                  final password = _account.getPassword('gw_cloud');
                  if (password == null) return;
                  Navigator.pushNamed(
                      context, CloudResetPasswordScreen.routeName,
                      arguments:
                          CloudResetPasswordScreenArgs(email: password.email));
                })),
          if (_subscriptions.isNotEmpty)
            PassyPadding(ThreeWidgetButton(
                center: Text(localizations.resetSyncData),
                left: const Padding(
                  padding: EdgeInsets.only(right: 30),
                  child: Icon(Icons.delete_rounded),
                ),
                right: const Icon(Icons.arrow_forward_ios_rounded),
                onPressed: () async {
                  String? token = _account.cloudToken;
                  if (token == null) {
                    showSnackBar(
                        message: localizations.cloudError,
                        icon: const Icon(Icons.cloud_off_rounded));
                    return;
                  }
                  bool? shouldReset = await showDialog<bool?>(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          shape: PassyTheme.dialogShape,
                          title: Text(localizations.resetSyncData),
                          actions: [
                            TextButton(
                              child: Text(
                                localizations.cancel,
                                style: TextStyle(
                                    color: PassyTheme.of(context)
                                        .highlightContentSecondaryColor),
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            TextButton(
                              child: Text(
                                localizations.reset,
                                style: TextStyle(
                                    color: PassyTheme.of(context)
                                        .highlightContentSecondaryColor),
                              ),
                              onPressed: () => Navigator.pop(context, true),
                            ),
                          ],
                        );
                      });
                  if (shouldReset != true) return;
                  await PassyCloud.lock(
                      token: token, deviceId: _account.deviceId);
                  await PassyCloud.reset(
                      token: token, deviceId: _account.deviceId);
                  await PassyCloud.releaseLock(
                      token: token, deviceId: _account.deviceId);
                })),
          PassyPadding(ThreeWidgetButton(
              center: Text(localizations.logOut),
              left: const Padding(
                padding: EdgeInsets.only(right: 30),
                child: Icon(Icons.logout_rounded),
              ),
              right: const Icon(Icons.arrow_forward_ios_rounded),
              onPressed: () async {
                _account.cloudToken = null;
                _account.cloudRefreshToken = null;
                _account.cloudEnabled = false;
                _account.saveSettings();
                await showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        shape: PassyTheme.dialogShape,
                        title: Text(localizations.passyCloudDisabled),
                        content: Text(localizations.passyCloudDisabled),
                        actions: [
                          TextButton(
                            child: Text(
                              localizations.done,
                              style: TextStyle(
                                  color: PassyTheme.of(context)
                                      .highlightContentSecondaryColor),
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      );
                    });
                Navigator.pop(context);
              })),
        ]));
  }
}
