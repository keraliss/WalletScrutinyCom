// Print some stats about verdicts and meta.
// node scripts/printStats.mjs > /tmp/stats.txt

// The following was used to create https://habla.news/a/naddr1qqxnzd3cxgcnywf5xg6rqwpnqyd8wumn8ghj7un9d3shjtnhv4kxcmmjv3jhytnwv46z7qg7waehxw309ahx7um5wgkhqatz9emk2mrvdaexgetj9ehx2ap0qywhwumn8ghj7mn0wd68ytnzd96xxmmfdejhytnnda3kjctv9uqsuamnwvaz7tmwdaejumr0dshszyrhwden5te0dehjuum5wghxxu30qgsydl97xpj74udw0qg5vkfyujyjxd3l706jd0t0w0turp93d0vvungrqsqqqa28mguzxj
// $ for v in $( awk '{print $2}' /tmp/stats.txt | sort -u ); do l=$v; t=0; for m in ok stale obsolete defunct discontinued; do i=$( cat /tmp/stats.txt | grep "^$m $v" | wc -l); l="$l $i"; t=$(( $t + $i )); done; echo $t $l; done | grep -v "^0 " | sort -nr | awk '{ good = $3; bad = $4 + $5 + $6 + $7; print "| [" $2 "](https://walletscrutiny.com/methodology/#" $2 ") | " good " | " bad " | comment |"}'
// | [fewusers](https://walletscrutiny.com/methodology/#fewusers) | 194 | 1229 | comment |
// | [custodial](https://walletscrutiny.com/methodology/#custodial) | 671 | 310 | comment |
// | [wip](https://walletscrutiny.com/methodology/#wip) | 202 | 639 | comment |
// | [nosource](https://walletscrutiny.com/methodology/#nosource) | 235 | 151 | comment |
// | [nowallet](https://walletscrutiny.com/methodology/#nowallet) | 146 | 119 | comment |
// | [nobtc](https://walletscrutiny.com/methodology/#nobtc) | 105 | 69 | comment |
// | [nosendreceive](https://walletscrutiny.com/methodology/#nosendreceive) | 84 | 30 | comment |
// | [vapor](https://walletscrutiny.com/methodology/#vapor) | 77 | 2 | comment |
// | [noita](https://walletscrutiny.com/methodology/#noita) | 32 | 12 | comment |
// | [ftbfs](https://walletscrutiny.com/methodology/#ftbfs) | 19 | 22 | comment |
// | [unreleased](https://walletscrutiny.com/methodology/#unreleased) | 34 | 6 | comment |
// | [fake](https://walletscrutiny.com/methodology/#fake) | 4 | 34 | comment |
// | [nonverifiable](https://walletscrutiny.com/methodology/#nonverifiable) | 20 | 16 | comment |
// | [diy](https://walletscrutiny.com/methodology/#diy) | 18 | 13 | comment |
// | [prefilled](https://walletscrutiny.com/methodology/#prefilled) | 12 | 11 | comment |
// | [plainkey](https://walletscrutiny.com/methodology/#plainkey) | 13 | 7 | comment |
// | [obfuscated](https://walletscrutiny.com/methodology/#obfuscated) | 8 | 9 | comment |
// | [reproducible](https://walletscrutiny.com/methodology/#reproducible) | 9 | 2 | comment |
// | [sealed-plainkey](https://walletscrutiny.com/methodology/#sealed-plainkey) | 6 | 3 | comment |
// | [sealed-noita](https://walletscrutiny.com/methodology/#sealed-noita) | 3 | 0 | comment |

import helper from './helper.mjs';
import helperPlayStore from './helperPlayStore.mjs';
import helperAppStore from './helperAppStore.mjs';
import helperHardware from './helperHardware.mjs';
import helperBearer from './helperBearer.mjs';
import helperDesktop from './helperDesktop.mjs';

async function run () {
  const r = {};
  const migration = function (header, body, fileName, categoryHelper) {
    const category = categoryHelper.category;
    if ('defunct,removed'.includes(header.meta) && header.verdict === 'reproducible') {
      console.log(header.appId);
    }
    r[header.meta] = (r[header.meta] ?? {});
    r[header.meta][header.verdict] = (r[header.meta][header.verdict] ?? 0);
    r[header.meta][header.verdict]++;
  };

  for await (const h of [helperPlayStore, helperAppStore, helperHardware, helperBearer, helperDesktop]) {
    helper.migrateAll(h, migration);
  }
  await new Promise(resolve => setTimeout(resolve, 3000));
  const metas = {};
  const verdicts = {};
  for (const meta in r) {
    metas[meta] = metas[meta] ?? 0;
    for (const verdict in r[meta]) {
      verdicts[verdict] = verdicts[verdict] ?? 0;
      verdicts[verdict] += r[meta][verdict];
      metas[meta] += r[meta][verdict];
    }
  }
  console.log(r, metas, verdicts);
}
run();
