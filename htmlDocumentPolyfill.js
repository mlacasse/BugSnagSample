import { DeviceInfo } from '@youi/react-native-youi';

const protocol = 'https';
const host = 'localhost';

const appName = 'BugSnagSample';
const appVersion = '0.0.1';

const browserName = 'Chrome';
const browserVersion = '83.0.4103.116';

const htmlEngineName = 'Safari';
const htmlEngineVersion = '537.36';

//Polyfill for creating getting a reference to a globalThis that works in any JS environment
(function () {
  if (typeof globalThis === 'object') {
    return;
  }
  // eslint-disable-next-line no-extend-native
  Object.defineProperty(Object.prototype, '__magic__', {
    get() {
      return this;
    },
    configurable: true,
  });
  // eslint-disable-next-line no-undef
  __magic__.globalThis = __magic__;
  delete Object.prototype.__magic__;
})();

// eslint-disable-next-line no-undef
globalThis.document = () => {};

globalThis.document.getElementsByTagName = () => [];
globalThis.document.addEventListener = () => {};
globalThis.document.querySelectorAll = () => {};
globalThis.document.createElement = () => {};

Object.defineProperty(document, 'documentElement', {
  get() {
    return {
      clientWidth: () => 0,
      clientHeight: () => 0,
      outerHTML: () => '',
    }
  },
  configurable: true,
});

// eslint-disable-next-line no-undef
globalThis.navigator = () => {};

Object.defineProperty(navigator, 'userAgent', {
  get() {
    return `${appName}/${appVersion} (${DeviceInfo.getDeviceManufacturer()} ${DeviceInfo.getDeviceType()}; ${DeviceInfo.getSystemVersion()}) ${browserName}/${browserVersion} ${htmlEngineName}/${htmlEngineVersion}`;
  },
  configurable: true,
});

Object.defineProperty(navigator, 'systemLanguage', {
  get() {
    return `${DeviceInfo.getDeviceLocale()}`;
  },
  configurable: true,
});

// eslint-disable-next-line no-undef
globalThis.location = () => {};

Object.defineProperty(location, 'protocol', {
  get() {
    return protocol;
  },
  configurable: true,
});

Object.defineProperty(location, 'host', {
  get() {
    return host;
  },
  configurable: true,
});

Object.defineProperty(location, 'href', {
  get() {
    return `${protocol}://${host}`;
  },
  configurable: true,
});

