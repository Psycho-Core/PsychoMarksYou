# Target-priority research notes

**Research snapshot:** 6 October 2026 · **Scope:** Classic dungeon/raid priorities relevant to WoW Forever, plus the new Forever dungeons and raids.

## Research and data policy

This is a targeted review of the most consequential tactics in selected instances, not a re-audit of every legacy Classic database row.

- Static marks, danger values, creature types, and CC-immunity flags are included only where sources support the claim and its use in a repeatable plan.
- When a tactic is supported but depends on the pack, wave, group composition, or raid assignment, the database may retain a **note-only** row. It has no default mark, danger, creature type, or CC-immunity value, so it does not contribute a fixed priority to automatic scoring.
- Unsupported and disputed mob rows are omitted. Unavailable content never receives inferred priorities based on its theme.
- **Provenance-noted rows** (added 6 Oct 2026): demo-sourced and client-roster-sourced content may now be encoded, but every such row must carry a `note` saying where it came from and that it is untested. This is a deliberate reversal of the earlier "omit demo-only rosters" rule — see *Reversal: demo and roster-only Forever content* below. `tests/test_databases.py` enforces the note requirement.
- General runtime heuristics (for example, recognition of a boss or caster) still apply to observed units independently of these database entries.

## Classic dungeons and raids

The Classic table previously existed only as `AutoMarkAssist_MobDB` (559 entries across 28 zones), while runtime lookup read `PsychoMarksYou_DefaultMobs`. The Classic module now merges the table into runtime lookup without replacing a pre-existing row; the legacy global remains available. Six source-supported mob rows were added in the first pass, and 35 more in the 6 October pass, bringing the table to 600 records. The review is selective; unmentioned legacy rows have not all been re-verified against every Forever build.

| Instance | Researched tactic | Database implementation |
| --- | --- | --- |
| Shadowfang Keep | Wailing Guardsmen cast a five-second AoE silence, not a fear. Fel Steeds hit hard but may be skipped; Moonwalkers have temporary magic immunity. | Wailing Guardsman is a high-priority target; Fel Steed and Moonwalker are note-only because their skip/shield mechanics do not establish a safe fixed mark. |
| Razorfen Downs | Ragglesnout can Dominate Mind and heal; interrupt the heal. | Added Ragglesnout as a critical target with the interruption note. |
| Scholomance | Pull caster rooms one pack at a time and back toward the entrance. Trash around Rattlegore hits hard and can stun tanks. Viewing-room elite students are commonly skipped unless needed for a quest. | Added Rattlegore and caster notes; the Student entry is note-only because it is commonly skipped unless questing. |
| Molten Core | Firelords spawn Lava Spawn adds, which should be killed as they appear. Ragnaros separately summons Sons of Flame. Lava Surgers threaten with knockback; some elementals can be controlled; giants need separate, one-at-a-time handling. | Corrected the Firelord-add note and made Lava Spawn a kill priority instead of `SKIP`. Sons of Flame remain a separate Ragnaros-phase entry. Context-dependent Firesworn, Annihilator, and giant tactics are note-only. |
| Blackwing Lair | Blackwing Technicians throw bombs and are kited/handled by a Hunter while the raid ignores them. On later mixed pulls, focus casters while tanks hold Overseers/Wyrmguards separately. | Technician is `SKIP` with a kite/ignore note. Overseer/Wyrmguard tactics are note-only because the raid plan determines their order. |
| Temple of Ahn'Qiraj (AQ40) | In paired packs, kill Qiraji Brainwashers before Vekniss Warriors; Warrior deaths spawn Vekniss Borers. In Wasp packs, the usual order is Qiraji Lasher, Wasps, then Stinger. A separate pre-C'Thun pack prioritizes Mindslayers before Champions and Slayers. Sentinel priority depends on ability rolls; Defender abilities require mechanic-specific handling. | Supported first/second targets use Skull/Cross. Ability-specific Sentinel/Defender advice and third targets without a dedicated kill-order icon are note-only. Obsidian Eradicator tactics are also note-only because pack context controls the order. |
| Naxxramas | Gothik priorities differ by side; living-side Riders are high priority, while some Death Knights can be Shackled. Kel'Thuzad phase-one Soldiers and Soul Weavers must be killed before reaching the raid. | Soldier of the Frozen Wastes and Soul Weaver have active ranged priorities. Gothik wave-side advice and the Kel'Thuzad melee-add note are note-only so the database does not apply one side-blind order. |

### Classic sources

- [Icy Veins — Shadowfang Keep](https://www.icy-veins.com/wow-classic/shadowfang-keep-dungeon-guide)
- [Icy Veins — Razorfen Downs](https://www.icy-veins.com/wow-classic/razorfen-downs-dungeon-guide)
- [Icy Veins — Scholomance](https://www.icy-veins.com/wow-classic/scholomance-dungeon-guide)
- [Icy Veins — Molten Core](https://www.icy-veins.com/wow-classic/molten-core-raid-guides), [Warcraft Tavern — Molten Core](https://www.warcrafttavern.com/wow-classic/guides/mc/), and [Amazon Basin — Molten Core](https://www.theamazonbasin.com/wiki/index.php/Molten_Core)
- [Icy Veins — Blackwing Lair](https://www.icy-veins.com/wow-classic/blackwing-lair-raid-guides)
- [Warcraft Tavern — AQ40](https://www.warcrafttavern.com/wow-classic/guides/temple-of-ahnqiraj-aq40/) and [Icy Veins — AQ40 trash](https://www.icy-veins.com/wow-classic/temple-of-ahn-qiraj-aq40-trash-guide)
- [Warcraft Tavern — Naxxramas](https://www.warcrafttavern.com/wow-classic/guides/naxxramas/) and [Icy Veins — Naxxramas](https://www.icy-veins.com/wow-classic/naxxramas-raid-guides)

## New WoW Forever content

### Current beta tactics represented in the database

- **Hall of Thanes:** Current beta guides support interrupting/stunning and focusing Dark Iron Summoners, which cast strong Fireballs and summon Fiery Assistants. Looters deal fast poison-dagger damage. Engineer bombs are avoidable by moving, so the Engineer has a note but no fixed mark. Method recommends clearing nearby Looters/patrols before Durgen, then killing Durgen before the Lesser Stone Golems. The active boss/add priorities follow those tactics; no extra mechanics are inferred for Faldrim Anvilmar or Plunder.
- **Ruins of Lordaeron:** Current guides support handling Flesh Golems and Living Monstrosities separately, killing Ragged Ghouls before ordinary Ghouls in mixed packs, and pulling back to avoid adjacent packs/patrols. Boss notes cover Witherfang's Leech Poison, The Baron's hard hits and heavy Knockout that knocks back and stuns the tank (keep the tank near full health; use stuns), The Abandoned's interruptible Life Drain, Bjork's patrol and nearby-Ghoul pull risk, and Rath'mael's Flamestrike. Some guides also describe threat loss on Knockout; the database note stays with the shared damage/knockback/stun advice. Shrieking Banshee and the Skeletal Soldier/Mage entries are note-only where the guide does not establish a special kill order.
- **Excavation Site: Wetlands:** Thicket Hunters apply Infected Wound; current guides advise CCing both, or controlling one and killing the other, with prompt dispels. Thicket Matriarchs call Lurkers when low, so clear other pack mobs before bursting them. Walking through tall grass can spawn Lurkers; stay on paths and fight on cleared ground. Those contextual add mechanics are notes, not fixed priorities. Saltspine, Shadetooth, and Relic Guardian have active boss priorities and sourced mechanic notes.

### Now encoded, with provenance notes

These four were previously omitted. They are now in the database because each has a
named mob or encounter roster from a specific source, and every row says so.

- **City of Dalaran (14 rows):** the beta client's own encounter list plus the
  documented trash behaviour — almost all trash is Arcane-immune, interrupt Mana
  Burn, kill the Angry Tomes before Unstable Sentinel, Kirin Tor Necromancers keep
  raising skeletons through the Underbelly ritual, Arcanic Enigma silences and
  brings two Mana Phantoms. Still **not playable in the beta**, so the rows carry
  that caveat. The roster disagreement is kept visible: Arcanic Enigma's note says
  Wowhead lists it and the client list does not.
- **The Drowned City (12 rows):** from the playable BlizzCon 2026 show-floor build.
  Deathless Sorcerer is the caster to interrupt; Deathless Guardian and Risen Sentry
  are why you do not combine packs. The boss roster is disputed — Zul'Alai, Zin'aka,
  Deathless Marrow and Min'loth appear in one source; Var'Taka, Captain Dreadrise and
  Gill appear in another. All seven are included, each noting which side it is on.
- **Barrow Deeps (9 rows) and Hyjal Summit (13 rows):** boss names only, from the
  BlizzCon demo roster and the beta client's Legacy achievement. No mechanics have
  been tested, so these rows carry the Skull mark a raid boss should get and nothing
  more. Every note says "mechanics untested".

### Still deliberately not encoded

- **Krol'dok Stronghold (40-45), Alcaz Prison (48-53), Blackmaw Hold (55-60),
  Shaper's Terrace (58-60):** every source checked lists these as
  *"Bosses: Unknown yet / Mob Packs: Unknown yet"* and none is playable. There are
  themes only — ogres with Twilight's Hammer influence, Defias versus naga, a
  corrupted furbolg city, a Titan facility with dinosaurs. Encoding mob names from a
  theme is exactly what the policy forbids, so these four zones have aliases but no
  rows. The runtime heuristics and auto-learn cover them in the meantime.

### Conflicting or incomplete names deliberately omitted

- **Hall of Thanes:** Current beta guides use **Magmatus**, while a client-derived roster uses **Infurnus**. Only the guide-supported encounter name is used for the active priority; the alternate name is omitted.
- **Ruins of Lordaeron:** Current beta guides call the abomination encounter **The Baron**; some client-derived lists say **The Butcher**. Lordaeron Captain appears in some sources as a rare/faction-specific encounter, but no stable priority is supported. Neither disputed/limited name is included in the mob database. Sources also differ on Bjork's ability (knockback versus a short anti-magic shield); the database keeps only the shared patrol/nearby-pull caution.
- **Excavation Site:** Client-derived roster data lists **Highland Horror**, but public beta guides disagree on whether it is a current boss and on the encounter count. It is omitted until that discrepancy is resolved.

### WoW Forever sources

- [Blizzard — Forever beta now live](https://worldofwarcraft.blizzard.com/en-us/news/24304160/the-world-of-warcraft-forever-beta-now-live), [Blizzard — October 1 beta development notes](https://us.forums.blizzard.com/en/wow/t/wow-forever-beta-development-notes-%E2%80%93-updated-october-1/2360696), and [Blizzard — What's Next panel recap](https://worldofwarcraft.blizzard.com/en-us/news/24303862/world-of-warcraft-forever-whats-next-panel-recap)
- [Icy Veins — October 1 beta Phase 2 update](https://www.icy-veins.com/wow-forever/news/everything-new-in-phase-2-of-the-wow-forever-beta-level-cap-dungeons-zones), which quotes Blizzard's clarification that City of Dalaran is scheduled for a future beta update
- [Warcraft Tavern — Forever dungeon overview](https://www.warcrafttavern.com/forever/guides/dungeons/)
- [Method — Hall of Thanes](https://www.method.gg/wow-forever/dungeons/hall-of-thanes) and [WoWForever.be — Hall of Thanes](https://wowforever.be/guides/dungeons/hall-of-thanes/)
- [Method — Ruins of Lordaeron](https://www.method.gg/wow-forever/dungeons/ruins-of-lordaeron) and [Icy Veins — Ruins of Lordaeron](https://www.icy-veins.com/wow-forever/ruins-of-lordaeron-guide)
- [Icy Veins — Excavation Site](https://www.icy-veins.com/wow-forever/excavation-site-wetlands-guide), [WoWForever.be — Excavation Site](https://wowforever.be/guides/dungeons/excavation-site-wetlands/), and [MMonster — Excavation Site](https://mmonster.co/wow-forever/guides/dungeons/excavation-site)
- [Wowhead — City of Dalaran guide](https://www.wowhead.com/forever/guide/city-of-dalaran-dungeon-overview-location-rewards) and the [October 5 evidence review](https://wowforeverguides.com/dungeons/city-of-dalaran)
- [Xaryu — City of Dalaran pre-beta run](https://www.youtube.com/watch?v=OGi-vMJRn60) and [ForeverChanges — documented BlizzCon demo encounters](https://foreverchanges.pro/dungeons/city-of-dalaran)
- [Warcraft Tavern — Drowned City show-floor preview](https://www.warcrafttavern.com/forever/news/the-drowned-city-dungeon-preview-in-wow-forever/)
- [EndgameTools — client-derived Forever dungeons/raids overview](https://endgametools.com/en/wow-forever/news/wow-forever-new-dungeons-raids) and its [City of Dalaran roster](https://endgametools.com/en/wow-forever/dungeons/city-of-dalaran)

Public guides, beta builds, and client-derived lists can disagree or lag as the beta changes. Re-check those sources before adding a mob row or automatic target priority.

## Danger rubric and what the addon does with it

Added 6 October 2026. Before this pass most rows carried a `mark` but no
`dangerLevel`, so `PMY.GetEffectiveDanger` fell back to 2 for everything in the
Skull/Cross band. Every healer, summoner and foot soldier scored identically and the
addon could not tell them apart. `dangerLevel` is what separates them:

| Level | Meaning | Score contribution |
| --- | --- | --- |
| 3 — Critical | Healers, summoners, fear / mind-control / silence, wipe risks | `1000 + 300` |
| 2 — High | Dangerous casters, AoE, cleave, enrage, knockback, heavy hitters | `1000 + 200` |
| 1 — Normal | Melee and pack filler | `500/1000 + 100` |

`PMY.ScoreMob` only separates the Skull/Cross band (`mark` 8/7) from the CC band
(`mark` 1-6), then adds `danger * 100`. So within one band, **`dangerLevel` is the
only thing that orders a pack.**

### Engine change: deterministic tie-breaking

With 141 danger-3 rows, ties inside a band became the normal case, and
`ScanAndMarkPack` sorted with a bare `a.score > b.score`. Lua's `table.sort` is not
stable, so the "first target" the addon announced was arbitrary run to run.
`PMY.SortByPriority` now breaks ties by database mark preference (Skull over Cross
over a CC mark) and then by name. It is a named function rather than an inline
closure so `tests/test_priority_order.py` can sort with the shipped comparator
instead of re-implementing the rule.

Note what this does *not* do: two mobs that share a mark **and** a danger level still
tie, and fall back to alphabetical order. Within the danger-3 band the data cannot
express "healer before summoner" — that would need a finer scale than 1-3 or a mark
preference difference.

### Classic pass: what changed, and how confident it is

Verified counts after the pass, from a real Lua VM:

| Table | Zones | Rows | d3 | d2 | d1 | note-only | SKIP |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `AutoMarkAssist_MobDB` | 28 | 600 | 141 | 249 | 126 | 22 | 61 |
| `PsychoMarksYou_DefaultMobs` | 35 | 676 | 158 | 301 | 126 | 28 | 62 |

**Guide-sourced (a named source states the ability or the kill order):**
Stratholme (Crimson Priest heals, Conjurer summons elementals, Sorcerer polymorphs,
Battle Mage AoE, banshee silence), Scarlet Monastery (Chaplain/Abbot/Friar heal,
Diviner Fireball, Conjuror fire pet, Wizard instant AoE, Myrmidon enrage),
Blackfathom Deeps (Blindlight Oracle heals/shields/Fears, Shadowmage Dominate Mind
plus Voidwalker, Acolyte heals, Aquamancer calls an Aqua Guardian),
Gnomeregan (Irradiated Horror Chain Burn, Machinesmith/Technician Supercharge and
Tune Up, alarm bots, mechanical CC immunity), Uldaman (Darkcaster volley and Mana
Burn, Relic Hunter Silence and Heal, Geologist Flame Spike and Shield Bash),
Lower Blackrock Spire (Scarshield Warlock portal, Evoker knockback/stun, Spire Spider
stun and spiderlings, Blackrock Summoner player-summon), Zul'Gurub
(Priest > Witch Doctor > Headhunter > Axe Thrower, Blood Drinker self-heal),
Dire Maul (Wildspawn Hellcaller/Felsworn/Trickster/Betrayer casts, Warpwood Guardian
Regrowth, Stomper War Stomp, Magister Kalendris mind control), Maraudon (satyr Gouge,
Shadowstalker stealth, Shambler Wild Regeneration, Noxious Cloud slimes),
Wailing Caverns (Druid of the Fang Healing Touch and Druid's Slumber),
The Deadmines (Taskmaster Piercing Shot, elite Overseers, fleeing Defias),
Zul'Farrak (Witch Doctor totems, Shadowcaster volley, Zealot CC, Blood Drinker),
Temple of Ahn'Qiraj (Anubisath Sentinel ability transfer, Qiraji Slayer silence and
on-death attack-power buff, Qiraji Lasher whirlwind), AQ20 (Qiraji Gladiator speed and
damage, Anubisath Guardian random abilities).

**Established Classic knowledge, not re-verified against a single guide this pass:**
the danger levels on filler mobs across every zone (`dangerLevel = 1`), the CC-mark
assignments on low-priority humanoids/beasts, and the raid add rankings in Blackwing
Lair, Molten Core and the Naxxramas Gothik/Kel'Thuzad adds. These are the rows most
worth re-checking against a current guide.

**Deliberately left note-only (22 rows):** pack-, wave- or raid-assignment-dependent
tactics where a fixed mark would be wrong — the Molten Core giants and Flamewaker
pack, Blackwing Lair Overseer/Wyrmguard, the AQ40 Sentinel/Defender/Eradicator/Slayer/
Stinger ability handling, and all eight Naxxramas Gothik and Kel'Thuzad adds. These
keep `note` only, so they encode no static priority.

### Sources added this pass

- [MmonsteR — Blackfathom Deeps](https://mmonster.co/wow-forever/guides/dungeons/blackfathom-deeps), [Gnomeregan](https://mmonster.co/wow-forever/guides/dungeons/gnomeregan), [Uldaman](https://mmonster.co/wow-forever/guides/dungeons/uldaman), [The Deadmines](https://mmonster.co/wow-forever/guides/dungeons/the-deadmines), [Maraudon](https://mmonster.co/wow-forever/guides/dungeons/maraudon), [Dire Maul: East](https://mmonster.co/wow-forever/guides/dungeons/dire-maul-east)
- [Wow pro — Jame's Stratholme guide](https://www.wow-pro.com/42-56-james-stratholme-guide/) and [Jame's Scarlet Monastery guide](https://www.wow-pro.com/33-40-james-scarlet-monastery-guide/)
- [Vanilla WoW Archive — Scarlet Monastery](https://vanilla-wow-archive.fandom.com/wiki/Scarlet_Monastery) and [Instance grouping guide](https://vanilla-wow-archive.fandom.com/wiki/Instance_grouping_guide)
- [OwnedCore — Lower Blackrock Spire guide](https://www.ownedcore.com/forums/world-of-warcraft/world-of-warcraft-guides/510-guide-lower-black-rock-spire.html), [Warcraft Wiki — LBRS walkthrough](https://warcraft.wiki.gg/wiki/Lower_Blackrock_Spire_walkthrough), [Hardchores — LBRS](https://hardchores.fandom.com/wiki/Lower_Blackrock_Spire)
- [Reddit r/classicwow — Zul'Gurub trash kill order](https://www.reddit.com/r/classicwow/comments/jfdoee/trash_kill_order_in_zulgurub/)
- [Icy Veins — AQ40 trash guide](https://www.icy-veins.com/wow-classic/temple-of-ahn-qiraj-aq40-trash-guide), [Icy Veins — Wailing Caverns](https://www.icy-veins.com/wow-classic/wailing-caverns-dungeon-guide)
- [Wowhead — mind-controllable mob abilities](https://wowpedia.fandom.com/wiki/List_of_mind_controllable_mobs)
- [Wowforeverguides — City of Dalaran](https://wowforeverguides.com/dungeons/city-of-dalaran), [ForeverChanges — Dalaran demo encounters](https://foreverchanges.pro/dungeons/city-of-dalaran), [MmonsteR — City of Dalaran](https://mmonster.co/wow-forever/guides/dungeons/city-of-dalaran)
- [ExpCarry — The Drowned City](https://expcarry.com/wow-forever-the-drowned-city-guide), [Mobalytics — The Drowned City](https://mobalytics.gg/wow-forever/dungeons/the-drowned-city-guide)
- [Warcraft Tavern — Forever dungeons](https://www.warcrafttavern.com/forever/guides/dungeons/) (the "Unknown yet" status of Krol'dok, Alcaz, Blackmaw and Shaper's Terrace)
- [Wowforeverbuilds — Hyjal Summit](https://wowforeverbuilds.com/raids/hyjal-summit), [WowClassicForever — Forever raids](https://wowclassicforever.info/raids/), [WoFwForever — dungeons and raids](https://wofwforever.com/en/guides/wow-forever-dungeons-raids/)
- [ExpCarry — Hall of Thanes](https://expcarry.com/wow-forever-hall-of-thanes-guide), used to add the boss mechanics (Faldrim's petrify curse, Magmatus' Combust, Plunder's knock-up, Durgen's AoE Fear) and to record that guides disagree on whether the Lesser Stone Golems die before or after Durgen
