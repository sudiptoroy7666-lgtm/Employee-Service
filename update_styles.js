const fs = require('fs');
const files = [
  'android/app/src/main/res/values/styles.xml',
  'android/app/src/main/res/values-v31/styles.xml',
  'android/app/src/main/res/values-night/styles.xml',
  'android/app/src/main/res/values-night-v31/styles.xml',
];
files.forEach(fp => {
  let c = fs.readFileSync(fp, 'utf8');
  c = c.replace(/Theme.Light.NoTitleBar/g, 'Theme.Material.Light.NoActionBar');
  c = c.replace(/<item name=" android:windowBackground\>@drawable\/launch_background<\/item>\r?\n/, '');
 c = c.replace(
 /(<style name=\NormalTheme\ parent=\@android:style\/Theme\.Material\.Light\.NoActionBar\>\s+<item name=\android:windowBackground\>\?android:colorBackground<\/item>)/,
 '' + String.fromCharCode(10) + ' <item name=\android:windowFullscreen\>true</item>' + String.fromCharCode(10) + ' <item name=\android:windowDrawsSystemBarBackgrounds\>true</item>'
 );
 fs.writeFileSync(fp, c);
 console.log('Updated:', fp);
});
