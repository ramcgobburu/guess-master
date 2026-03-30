'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "8d0701d9922ca12fa8645a40fd27dea4",
"favicon%202.png": "5dcef449791fa27946b3d35ad8803796",
"version.json": "cb5fd1bbfba67a7f54aae7e5959f06f9",
"index.html": "7368bb6f07f531ea828389aea1aab8d2",
"/": "7368bb6f07f531ea828389aea1aab8d2",
"main.dart.js": "f85741429d53395c7c5743ad55d5f1da",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"favicon.png": "096c10e39dd92f99ff74126f4f36d4e0",
"icons/Icon-maskable-192%202.png": "af9cc585b45e549c9087a8bbea567c7d",
"icons/Icon-192%202.png": "af9cc585b45e549c9087a8bbea567c7d",
"icons/Icon-192.png": "651babf5fd26cb94482dcd609dc23406",
"icons/Icon-maskable-192.png": "651babf5fd26cb94482dcd609dc23406",
"icons/Icon-maskable-512%202.png": "876a2ce633cf72c1da1a9aa5a7a6c617",
"icons/Icon-512%202.png": "876a2ce633cf72c1da1a9aa5a7a6c617",
"icons/Icon-maskable-512.png": "d994ea7d23d84230c20dfc12da8bf6fa",
"icons/Icon-512.png": "d994ea7d23d84230c20dfc12da8bf6fa",
"manifest.json": "41f74a71a392c3504c85df22460f53c2",
".git/config": "c10a597fb06caae7e0d960f807f0c7bf",
".git/objects/0d/13d229f1f975839510c38a534acff109fd954b": "115ac036dca959686545a2c132718df5",
".git/objects/59/f62de31960687e47e125fda560083707f6faa9": "5be6af9cfe53ddee8f5061f7454758d1",
".git/objects/68/43fddc6aef172d5576ecce56160b1c73bc0f85": "2a91c358adf65703ab820ee54e7aff37",
".git/objects/6f/7661bc79baa113f478e9a717e0c4959a3f3d27": "985be3a6935e9d31febd5205a9e04c4e",
".git/objects/69/b2023ef3b84225f16fdd15ba36b2b5fc3cee43": "6ccef18e05a49674444167a08de6e407",
".git/objects/51/03e757c71f2abfd2269054a790f775ec61ffa4": "d437b77e41df8fcc0c0e99f143adc093",
".git/objects/67/b2cfe766d98cdceb53b1a8be4ff338835d93cf": "c5d5b83f5406d02df063ac1748c56de0",
".git/objects/93/b363f37b4951e6c5b9e1932ed169c9928b1e90": "c8d74fb3083c0dc39be8cff78a1d4dd5",
".git/objects/0e/9cb1c2beb2bee71d42df65fcfb83baf475effe": "31c348f3654644e1e2d328d965c18651",
".git/objects/9c/30c28686b35140b51ffc77314233c95b53f323": "99c226a69adc7ef4d80c5ad250c39846",
".git/objects/d9/5b1d3499b3b3d3989fa2a461151ba2abd92a07": "a072a09ac2efe43c8d49b7356317e52e",
".git/objects/ad/ced61befd6b9d30829511317b07b72e66918a1": "37e7fcca73f0b6930673b256fac467ae",
".git/objects/ad/1466b6bc7562a4a58fbaae2811db41b14cc94c": "99ffe58e8348a92c11b49f6e5bd6d2e2",
".git/objects/bb/0f2698338e4211c8e4a410aceb90a70a62a428": "d51ccc5ba55484552a894c2529040b90",
".git/objects/d7/7cfefdbe249b8bf90ce8244ed8fc1732fe8f73": "9c0876641083076714600718b0dab097",
".git/objects/b3/9236cbb26314d5b8b24f484551053a1c21468a": "dc8868883f467f26d7263669dd582103",
".git/objects/d8/58bd17c73986b323327de49c92ee432e95d949": "c03c322e8ecc49d2e3552fd361619d4d",
".git/objects/f3/3e0726c3581f96c51f862cf61120af36599a32": "afcaefd94c5f13d3da610e0defa27e50",
".git/objects/fd/05cfbc927a4fedcbe4d6d4b62e2c1ed8918f26": "5675c69555d005a1a244cc8ba90a402c",
".git/objects/f5/72b90ef57ee79b82dd846c6871359a7cb10404": "e68f5265f0bb82d792ff536dcb99d803",
".git/objects/e4/bd0e1296eaa5fa78022549b748876e44625b07": "22b28525a643fdcca181608fa32fecb6",
".git/objects/c8/3af99da428c63c1f82efdcd11c8d5297bddb04": "144ef6d9a8ff9a753d6e3b9573d5242f",
".git/objects/c1/295cbe75d3eba866df9cbd35e0e7e5dafbcd60": "7b91b8a533d45fa9af664b08f6f860ad",
".git/objects/27/2f74b967c014b433a495eb02555ddf0bc80a5b": "03053c144c8e6345f00f0181460d8a4e",
".git/objects/7d/2b656957f5ed697e99c81ad642dd3dec86d1d6": "3232de49d06925adcd054de4e5f989a8",
".git/objects/29/5a4e54b0b78086476e21d6d58e488d32b97de4": "2c8c4a7b2a3c3af4f6bc9c0f193bcd3b",
".git/objects/7c/3463b788d022128d17b29072564326f1fd8819": "37fee507a59e935fc85169a822943ba2",
".git/objects/16/f6c03a960438c7f51b162c334083a264e28b97": "98e13f115f820fa829769c9cc591095d",
".git/objects/73/b3202a9e5cff376077e1c88b41573ab9890907": "579d301d33dc235325a14e3fdb6f8b2f",
".git/objects/87/aa80af14682d29b73d5cd0c834a1646659bf88": "d20b6329011ec32229fec77d205b7947",
".git/objects/80/a0c0cfee8c8633e93c552386d270e2c48f7021": "cbd2786d8be7a7f1f97e3979bf988bcc",
".git/objects/28/e4773075f0d923d2744f97bfb9076b2ac516e2": "8d204f28e368f81ce12bc29d5a8f6a2d",
".git/objects/8a/aa46ac1ae21512746f852a42ba87e4165dfdd1": "1d8820d345e38b30de033aa4b5a23e7b",
".git/objects/72/c27e64a490f8a1df851ef107579ece2c7e86fa": "ff1a8232e1a70fd340d9535fc8e05235",
".git/objects/2a/c41c623c5c6aaf765b14aa5fbb8ac126cb9c1f": "c176d81dc98bc0794f6cdf20c8534b8c",
".git/objects/6b/9862a1351012dc0f337c9ee5067ed3dbfbb439": "85896cd5fba127825eb58df13dfac82b",
".git/objects/5d/7e1cd3d79b3168574d762812e836f5764e5918": "3bf8f79af2aaaf939a71ed89c060c495",
".git/objects/3a/8cda5335b4b2a108123194b84df133bac91b23": "1636ee51263ed072c69e4e3b8d14f339",
".git/objects/5e/8944f8f54a2678ba564289c5566e81b3dac3b9": "f957c2906672de6409646bfc9bc9bcac",
".git/objects/5b/e1dc50116a47e5ab04e2c3127cace55c93b432": "9f1da6f8a444da33b0716bccb963ff9e",
".git/objects/08/27c17254fd3959af211aaf91a82d3b9a804c2f": "360dc8df65dabbf4e7f858711c46cc09",
".git/objects/6d/ec2da8ad1694aa3fbc978811620ebe4bd1352e": "18cc8720ffee5c13d5448d4e65cac571",
".git/objects/06/3c36cc86d3b5216b335d7b4786da963564ebf4": "9b520482d874bc84ac109a0e9fa66618",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d5/64d0bc3dd917926892c55e3706cc116d5b165e": "ab5f20dcd5b558888db7d80b0f979f8a",
".git/objects/a8/47b5980cd4b8fbed1193ae26931e32e6b0dee9": "b2eef2243cfd0b0bb3cf147622f86c0e",
".git/objects/b9/3e39bd49dfaf9e225bb598cd9644f833badd9a": "666b0d595ebbcc37f0c7b61220c18864",
".git/objects/a1/985ec5cb56201f7e431f6fb31135d774a347f8": "40b7ce2122e8db7eaf644758406ebcf3",
".git/objects/e1/1cd33316c3667ac10a9814f436eef0d33774d8": "8088ae05b6cc97ca0a6b61c6aad59d2f",
".git/objects/e1/885ba48398878261f708a8382785eeab398d4c": "c148b580e32cba6c219875e62fad0579",
".git/objects/cd/176f0220c3024539dc07240ecda5469418acfb": "a6c5f9d6f705df3181d592638ce817bc",
".git/objects/cc/deb43127e00878c8857158a8915d1e3c20f4f6": "78d5d62a110c50b81bc2ec47da68af07",
".git/objects/e6/eb8f689cbc9febb5a913856382d297dae0d383": "466fce65fb82283da16cdd7c93059ff3",
".git/objects/e6/9de29bb2d1d6434b8b29ae775ad8c2e48c5391": "c70c34cbeefd40e7c0149b7a0c2c64c2",
".git/objects/f6/e6c75d6f1151eeb165a90f04b4d99effa41e83": "95ea83d65d44e4c524c6d51286406ac8",
".git/objects/e9/94225c71c957162e2dcc06abe8295e482f93a2": "2eed33506ed70a5848a0b06f5b754f2c",
".git/objects/46/4ab5882a2234c39b1a4dbad5feba0954478155": "2e52a767dc04391de7b4d0beb32e7fc4",
".git/objects/15/4c2a72a52b94d7e6e035a34e2a560288d4f592": "6f8a8621a138c7a37fe9c7d5c772f834",
".git/objects/85/63aed2175379d2e75ec05ec0373a302730b6ad": "997f96db42b2dde7c208b10d023a5a8e",
".git/HEAD": "5ab7a4355e4c959b0c5c008f202f51ec",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "b2b0e03168aceb5ed89e8c668a82d9a4",
".git/logs/refs/heads/gh-pages": "b2b0e03168aceb5ed89e8c668a82d9a4",
".git/logs/refs/remotes/origin/gh-pages": "115406d9beae9372a5b649e058ae8b5c",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/refs/heads/gh-pages": "5e55b3205dda0aa0b62ffdc671cb0b81",
".git/refs/remotes/origin/gh-pages": "5e55b3205dda0aa0b62ffdc671cb0b81",
".git/index": "b7c8ef0b947e1a50bc34c6bb09cc48d5",
".git/COMMIT_EDITMSG": "1f0a06a3d3787de6cdf63c37ad7cfa41",
"assets/NOTICES": "c144d43cc267184a4cfd727d20c23aab",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "1735f18715c556bc311caecd4ea56375",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"assets/AssetManifest.bin": "826d380b2ef0f68e86eaeb58af251772",
"assets/fonts/MaterialIcons-Regular.otf": "aab48f73093123f7d0216dade6315448",
"assets/assets/teams/kkr.png": "a91d25eba8507941181c77dade3ce636",
"assets/assets/teams/csk.png": "95c1d0df2296b08e2ac64abfac029573",
"assets/assets/teams/rr.png": "8985816547e0257d1b07ebae3b3b1322",
"assets/assets/teams/gt.png": "4e2df808b7817d30c6230f64059c6f4a",
"assets/assets/teams/lsg.png": "a45bda7d9d4e39eb86a8346af4bada16",
"assets/assets/teams/rcb.png": "a4f56a2e2156b035178b8ef43112d7b9",
"assets/assets/teams/dc.png": "0920532ddda76dda470c27b5a4d2909a",
"assets/assets/teams/pbks.png": "d1981ac0617131df60976f6cfc328935",
"assets/assets/teams/srh.png": "ce5f1ce538b20434c2e129a96a62d9ed",
"assets/assets/teams/mi.png": "6fe85a9f62da3f9889102962052856d1",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
