/**
 * Creating a sidebar enables you to:
 - create an ordered group of docs
 - render a sidebar for each doc of that group
 - provide next/previous navigation

 The sidebars can be generated from the filesystem, or explicitly defined here.

 Create as many sidebars as you want.
 */

// @ts-check

/** @type {import('@docusaurus/plugin-content-docs').SidebarsConfig} */
const sidebars = {
  spec: [
    'spec-overview',
    {
      type: 'category',
      label: 'Messages',
      link: {
        type: 'doc',
        id: 'spec/messages',
      },
      items: [
        'spec/messages-request',
        'spec/messages-response'
      ]
    },
    'spec/batch',
    'spec/encryption',
    'spec/handshake',
    'spec/verification',
    'spec/multi-chain',
    'spec/network',
  ],
  clientSdk: [
    "client-sdk/mobile-sdk-overview",
    {
      type: "category",
      label: "iOS",
      items: [
        "client-sdk/ios-install",
        "client-sdk/ios-setup",
        "client-sdk/ios-establishing-a-connection",
        "client-sdk/ios-making-requests",
        "client-sdk/ios-api-reference"
      ]
    },
    {
      type: "category",
      label: "Android",
      items: [
        "client-sdk/android-install",
        "client-sdk/android-setup",
        "client-sdk/android-establishing-a-connection",
        "client-sdk/android-making-requests",
        "client-sdk/android-api-reference"
      ]
    }
  ],
  
};

module.exports = sidebars;
