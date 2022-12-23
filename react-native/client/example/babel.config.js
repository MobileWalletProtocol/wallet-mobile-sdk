const path = require('path');

const libraryIndex = path.join(__dirname, '..', 'src', 'index.ts');

module.exports = function (api) {
  api.cache(true);
  return {
    presets: ['babel-preset-expo'],
    plugins: [
      [
        'module-resolver',
        {
          extensions: ['.tsx', '.ts', '.js', '.json'],
          alias: {
            // For development, we want to alias the library to the source
            '@coinbase/wallet-mobile-sdk': libraryIndex,
          },
        },
      ],
    ],
  };
};
