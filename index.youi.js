/**
 * Basic You.i RN app
 */
import React, { Component } from "react";
import { AppRegistry, Image, StyleSheet, Text, View } from "react-native";
import { DeviceInfo, FormFactor } from "@youi/react-native-youi";

import './htmlDocumentPolyfill';

import Bugsnag from '@bugsnag/js'

const { _globalHandler, getGlobalHandler, setGlobalHandler } = global.ErrorUtils;

export default class YiReactApp extends Component {
  constructor(props) {
    super(props);

    // Initialize Bugsnag to begin tracking errors. Only an api key is required, but
    // here are some other helpful configuration details:
    Bugsnag.start({
      // get your own api key at bugsnag.com
      apiKey: 'ec866230dd7116c94845586bafc31326',

      // if you track deploys or use source maps, make sure to set the correct version.
      appVersion: '0.0.1',

      // defines the release stage for all events that occur in this app.
      releaseStage: 'development',

      //  defines which release stages bugsnag should report. e.g. ignore staging errors.
      enabledReleaseStages: [ 'development', 'production' ],

      //  defines which breadcrumb types we want to track
      enabledBreadcrumbTypes: ['log', 'state', 'error', 'manual'],

      //  we're not a website
      trackInlineScripts: false,
    });

    // intercept react-native error handling
    this.defaultHandler = getGlobalHandler && getGlobalHandler() || _globalHandler;

    // feed errors directly to our wrapGlobalHandler function
    setGlobalHandler((exception, isFatal) => {
      Bugsnag.notify(exception, event => {
        event.context = 'Unhandled exception';
        // Note that metadata can be declared globally, in the notification (as below) or in an onError.
        // The below metadata will be supplemented (not replaced) by the metadata
        // in the onError method. See our docs if you prefer to overwrite/remove metadata.
        event.addMetadata('details', {
          info: 'Any important details specific to the context of this particular error/function.',
          deviceId: DeviceInfo.getDeviceId(),
          systemName: DeviceInfo.getSystemName(),
          systemVersion: DeviceInfo.getSystemVersion(),
          manufacturer: DeviceInfo.getDeviceManufacturer(),
          deviceType: DeviceInfo.getDeviceType(),
          deviceModel: DeviceInfo.getDeviceModel(),
          isFatal,
        });
        event.setUser('0001', 'marc.lacasse@youi.tv', 'Marc Lacasse');
      });

      this.defaultHandler(exception, isFatal);
    });
  }

  componentDidMount() {
    Bugsnag.leaveBreadcrumb('componentDidMount');

    // This will trigger an unhandled exception since you can't convert a
    // number to an uppercase letter.
    const num = 0;
    const str = num.toUpperCase();
  }

  render() {
    Bugsnag.leaveBreadcrumb('render');

    return (
      <View style={styles.mainContainer}>
        <View style={styles.headerContainer}>
          <View
            style={styles.imageContainer}
            focusable={true}
            accessible={true}
            accessibilityLabel="You i TV logo"
            accessibilityHint="Image in your first app"
            accessibilityRole="image"
          >
            <Image
              style={styles.image}
              source={{ uri: "res://drawable/default/youi_logo_red.png" }}
            />
          </View>
        </View>
        <View style={styles.bodyContainer} focusable={true} accessible={true}>
          <Text
            style={styles.headlineText}
            accessibilityLabel="Welcome to your first You I React Native app"
          >
            Welcome to your first You.i React Native app!
          </Text>
          <Text
            style={styles.bodyText}
          >
            For more information on where to go next visit
          </Text>
          <Text
            style={styles.bodyText}
            accessibilityLabel="https://developer dot you i dot tv"
          >
            https://developer.youi.tv
          </Text>
        </View>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  mainContainer: {
    backgroundColor: "#e6e7e7",
    flex: 1
  },
  headerContainer: {
    backgroundColor: "#ffffff",
    justifyContent: "center",
    alignItems: "center",
    flex: 2
  },
  imageContainer: {
    justifyContent: "center",
    alignItems: "center",
    flex: 2
  },
  image: {
    height: FormFactor.isTV ? 225 : 75,
    width: FormFactor.isTV ? 225 : 75,
    resizeMode: "contain"
  },
  bodyContainer: {
    alignItems: "center",
    justifyContent: "center",
    flex: 1
  },
  headlineText: {
    marginBottom: 10,
    color: "#333333",
    textAlign: "center"
  },
  bodyText: {
    color: "#333333",
    textAlign: "center"
  }
});

AppRegistry.registerComponent("YiReactApp", () => YiReactApp);
