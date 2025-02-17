const path = require('path');
const ZipPlugin = require('zip-webpack-plugin');
const packageJson = require('./package.json');

module.exports = {
  mode: "production",
  target: "node",
  entry: {
    index: {
      import: './handler.ts',
      dependOn: ['vendor'],
      library: {
        type: 'commonjs-module'
      }
    },
    vendor: Object.keys(packageJson.dependencies)
  },
  output: {
    filename: '[name].js',
    path: path.resolve(__dirname, 'dist'),
    chunkFormat: 'commonjs'
  },
  plugins: [
    new ZipPlugin({
      filename: 'app.zip',
      include: [/\.js$/],
      fileOptions: {
        compress: true
      }
    })
  ],
  module: {
    rules: [
      {
        test: /\.ts$/,
        use: 'ts-loader',
        exclude: /node_modules/,
      }
    ],
  },
  resolve: {
    extensions: ['.ts', '.js'],
    modules: ['node_modules']
  },
  optimization: {
    minimize: true
  },
  externals: ['aws-sdk'],
  externalsType: 'commonjs-module',
  externalsPresets: {
    node: true,
  // },
  // experiments: {
  //   outputModule: true
  }
};
