# Target-priority research notes

**Research snapshot:** 6 October 2026 · **Scope:** Classic dungeon/raid priorities relevant to WoW Forever, plus the new Forever dungeons and raids.

## Research and data policy

This is a targeted review of the most consequential tactics in selected instances, not a re-audit of every legacy Classic database row.

- Static marks, danger values, creature types, and CC-immunity flags are included only where sources support the claim and its use in a repeatable plan.
- When a tactic is supported but depends on the pack, wave, group composition, or raid assignment, the database may retain a **note-only** row. It has no default mark, danger, creature type, or CC-immunity value, so it does not contribute a fixed priority to automatic scoring.
- Unsupported, disputed, roster-only, or demo-only mob rows are omitted rather than kept behind a confidence/status label or runtime gate. Unavailable content does not receive inferred priorities based on its theme.
- General runtime heuristics (for example, recognition of a boss or caster) still apply to observed units independently of these database entries.

## Classic dungeons and raids

The Classic table previously existed only as `AutoMarkAssist_MobDB` (559 entries across 28 zones), while runtime lookup read `PsychoMarksYou_DefaultMobs`. The Classic module now merges the table into runtime lookup without replacing a pre-existing row; the legacy global remains available. Six source-supported mob rows were added, bringing the table to 565 records. The review is selective; unmentioned legacy rows have not all been re-verified against every Forever build.

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

### Researched but not encoded as mob-priority rows

The latest reviewed public-beta roster is Blizzard's October 1 update (level cap 30). It added Excavation Site: Wetlands and listed Hall of Thanes and Ruins of Lordaeron among the available dungeons, but not City of Dalaran. Blizzard's October 1 clarification said Dalaran would come in a future beta update; the October 5 guide check still reports it unavailable.

- **City of Dalaran:** There is more than a client roster: Xaryu's September 13 pre-beta run shows a full early build, and Wowhead's October 1 guide reports specific trash advice (focus non-elite Mana Phantoms and interrupt Mana Burn; kill Angry Tomes before Unstable Sentinel; use Saturated Remnants' mana fields). However, Wowhead explicitly warns that unavailable-dungeon data may come from Classic or its database and may be incomplete or inaccurate. The published boss lists also disagree: Wowhead's guide includes Arcanic Enigma, while the client-derived encounter list instead includes Mana Devourer, Mana Elemental, and Mana Wraith. Since those mob tactics and names have not been checked in the current public beta, none of the preview/database-only mobs are added as default rows or priorities.
- **The Drowned City:** Warcraft Tavern's detailed account is from a BlizzCon show-floor demo, not the current beta. It describes Makrura, Risen Sentries, naga, tight packs/patrols, and boss risks such as Zul'Alai's low-health enrage and tank pressure at Zin'aka/Deathless Marrow. The available coverage does not establish a repeatable trash kill order for the current build; no mob rows or marks are included.
- **Krol'dok Stronghold, Alcaz Prison, Blackmaw Hold, and Shaper's Terrace:** Public material establishes announced level bands, settings, and broad premises, not dependable mob names or tactics. No mob priorities have been inferred from a dungeon's theme or client rosters.
- **Barrow Deeps and Hyjal Summit:** The roadmap and client Legacy challenges establish future raid names/encounter rosters, but there are no playable encounter tactics yet. No raid mob rows, CC claims, or kill orders are included.

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
