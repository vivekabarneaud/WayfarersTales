using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Text;

public class LRef { public string Name; public LRef(string n) { Name = n; } }

public class LTable {
  public List<object> Arr = new List<object>();
  public List<KeyValuePair<object, object>> Map = new List<KeyValuePair<object, object>>();
  public string Comment;
  public object Get(string key) {
    foreach (var kv in Map) { if (kv.Key is string && (string)kv.Key == key) return kv.Value; }
    return null;
  }
}

public class Tok { public string Type; public string Text; public int Line; }

public class LuaFile {
  public List<Tok> Toks = new List<Tok>();
  public Dictionary<int, string> Comments = new Dictionary<int, string>();
  public Dictionary<string, LTable> Locals = new Dictionary<string, LTable>();
  public Dictionary<string, LTable> Globals = new Dictionary<string, LTable>();
  int p;

  public LuaFile(string path) {
    Tokenize(File.ReadAllText(path, Encoding.UTF8));
    ParseTop();
  }

  void Tokenize(string s) {
    int i = 0, line = 1, n = s.Length;
    while (i < n) {
      char c = s[i];
      if (c == '\n') { line++; i++; continue; }
      if (char.IsWhiteSpace(c)) { i++; continue; }
      if (c == '-' && i + 1 < n && s[i + 1] == '-') {
        if (i + 3 < n && s[i + 2] == '[' && s[i + 3] == '[') {
          int e = s.IndexOf("]]", i + 4); if (e < 0) e = n - 2;
          for (int k = i; k < e; k++) if (s[k] == '\n') line++;
          i = e + 2; continue;
        }
        int end = s.IndexOf('\n', i); if (end < 0) end = n;
        string cm = s.Substring(i + 2, end - i - 2).Trim();
        if (!Comments.ContainsKey(line)) Comments[line] = cm;
        i = end; continue;
      }
      if (c == '"' || c == '\'') {
        var sb = new StringBuilder(); int j = i + 1;
        while (j < n && s[j] != c) {
          if (s[j] == '\\' && j + 1 < n) {
            char x = s[j + 1];
            if (x == 'n') sb.Append('\n'); else if (x == 't') sb.Append('\t'); else sb.Append(x);
            j += 2; continue;
          }
          if (s[j] == '\n') line++;
          sb.Append(s[j]); j++;
        }
        Toks.Add(new Tok { Type = "S", Text = sb.ToString(), Line = line });
        i = j + 1; continue;
      }
      if (c == '[' && i + 1 < n && s[i + 1] == '[') {
        int e = s.IndexOf("]]", i + 2); if (e < 0) e = n - 2;
        string str = s.Substring(i + 2, e - i - 2);
        Toks.Add(new Tok { Type = "S", Text = str, Line = line });
        foreach (char ch in str) if (ch == '\n') line++;
        i = e + 2; continue;
      }
      if (char.IsDigit(c)) {
        int j = i; while (j < n && (char.IsLetterOrDigit(s[j]) || s[j] == '.')) j++;
        Toks.Add(new Tok { Type = "N", Text = s.Substring(i, j - i), Line = line }); i = j; continue;
      }
      if (char.IsLetter(c) || c == '_') {
        int j = i; while (j < n && (char.IsLetterOrDigit(s[j]) || s[j] == '_')) j++;
        Toks.Add(new Tok { Type = "W", Text = s.Substring(i, j - i), Line = line }); i = j; continue;
      }
      string two = i + 1 < n ? s.Substring(i, 2) : "";
      if (two == ".." || two == "==" || two == "~=" || two == "<=" || two == ">=") {
        if (two == ".." && i + 2 < n && s[i + 2] == '.') { Toks.Add(new Tok { Type = "P", Text = "...", Line = line }); i += 3; continue; }
        Toks.Add(new Tok { Type = "P", Text = two, Line = line }); i += 2; continue;
      }
      Toks.Add(new Tok { Type = "P", Text = c.ToString(), Line = line }); i++;
    }
  }

  Tok T(int k) { return k < Toks.Count ? Toks[k] : new Tok { Type = "E", Text = "", Line = 0 }; }
  bool Is(int k, string text) { var t = T(k); return t.Type == "P" && t.Text == text; }

  void ParseTop() {
    int i = 0;
    while (i < Toks.Count) {
      try {
        // local NAME = {
        if (T(i).Type == "W" && T(i).Text == "local" && T(i + 1).Type == "W" && Is(i + 2, "=") && Is(i + 3, "{")) {
          p = i + 3; var t = ParseTable(); Locals[T(i + 1).Text] = t; i = p; continue;
        }
        // A.B.C = {   (start of a name chain)
        if (T(i).Type == "W" && !(i > 0 && Is(i - 1, "."))) {
          int j = i; string name = T(i).Text;
          while (Is(j + 1, ".") && T(j + 2).Type == "W") { name += "." + T(j + 2).Text; j += 2; }
          if (j > i && Is(j + 1, "=") && Is(j + 2, "{")) {
            p = j + 2; var t = ParseTable(); Globals[name] = t; i = p; continue;
          }
        }
      } catch (Exception) { }
      i++;
    }
  }

  LTable ParseTable() {
    // at "{"
    var t = new LTable();
    int openLine = T(p).Line;
    string cm; if (Comments.TryGetValue(openLine, out cm)) t.Comment = cm;
    p++;
    while (!Is(p, "}")) {
      if (T(p).Type == "E") throw new Exception("eof");
      if (Is(p, "[") ) {
        p++; object key = ParseExpr(); if (!Is(p, "]")) throw new Exception("]"); p++;
        if (!Is(p, "=")) throw new Exception("="); p++;
        object val = ParseExpr(); t.Map.Add(new KeyValuePair<object, object>(key, val));
      } else if (T(p).Type == "W" && Is(p + 1, "=")) {
        string key = T(p).Text; p += 2;
        object val = ParseExpr(); t.Map.Add(new KeyValuePair<object, object>(key, val));
      } else {
        t.Arr.Add(ParseExpr());
      }
      if (Is(p, ",") || Is(p, ";")) p++;
    }
    p++;
    return t;
  }

  static readonly HashSet<string> BinOps = new HashSet<string> { "..", "+", "-", "*", "/", "%", "^", "==", "~=", "<", ">", "<=", ">=" };

  object ParseExpr() {
    object left = ParsePrimary();
    while (true) {
      var t = T(p);
      bool isOp = (t.Type == "P" && BinOps.Contains(t.Text)) || (t.Type == "W" && (t.Text == "and" || t.Text == "or"));
      if (!isOp) break;
      string op = t.Text; p++;
      object right = ParsePrimary();
      if (op == ".." && left is string && right is string) left = (string)left + (string)right;
      else left = new LRef("expr");
    }
    return left;
  }

  object ParsePrimary() {
    var t = T(p);
    if (t.Type == "S") { p++; return t.Text; }
    if (t.Type == "N") { p++; double d; double.TryParse(t.Text, NumberStyles.Float, CultureInfo.InvariantCulture, out d); return d; }
    if (Is(p, "{")) return ParseTable();
    if (Is(p, "-")) { p++; object v = ParsePrimary(); if (v is double) return -(double)v; return new LRef("expr"); }
    if (Is(p, "(")) { p++; object v = ParseExpr(); if (Is(p, ")")) p++; return v; }
    if (t.Type == "W") {
      if (t.Text == "true") { p++; return true; }
      if (t.Text == "false") { p++; return false; }
      if (t.Text == "nil") { p++; return null; }
      if (t.Text == "not") { p++; ParsePrimary(); return new LRef("expr"); }
      if (t.Text == "function") { SkipFunction(); return new LRef("function"); }
      string name = t.Text; p++;
      while (true) {
        if (Is(p, ".") && T(p + 1).Type == "W") { name += "." + T(p + 1).Text; p += 2; }
        else if (Is(p, "[")) { p++; ParseExpr(); if (Is(p, "]")) p++; name += "[]"; }
        else if (Is(p, "(")) { SkipBalanced("(", ")"); name += "()"; }
        else if (Is(p, ":") && T(p + 1).Type == "W") { name += ":" + T(p + 1).Text; p += 2; }
        else break;
      }
      return new LRef(name);
    }
    throw new Exception("unexpected " + t.Text);
  }

  void SkipBalanced(string open, string close) {
    int depth = 0;
    do {
      if (Is(p, open)) depth++; else if (Is(p, close)) depth--;
      p++;
    } while (depth > 0 && T(p).Type != "E");
  }

  void SkipFunction() {
    int depth = 0;
    do {
      var t = T(p);
      if (t.Type == "W" && (t.Text == "function" || t.Text == "do" || t.Text == "then" || t.Text == "repeat")) depth++;
      if (t.Type == "W" && (t.Text == "end" || t.Text == "until")) depth--;
      p++;
    } while (depth > 0 && T(p).Type != "E");
  }
}

public static class Extractor {
  static StringBuilder Out;
  static bool First;
  static LuaFile Cur;

  static string J(string s) {
    if (s == null) return "null";
    var sb = new StringBuilder("\"");
    foreach (char c in s) {
      if (c == '"') sb.Append("\\\""); else if (c == '\\') sb.Append("\\\\");
      else if (c == '\n') sb.Append("\\n"); else if (c == '\r') { } else if (c == '\t') sb.Append(" ");
      else if (c < 32) { } else sb.Append(c);
    }
    return sb.Append("\"").ToString();
  }

  static string ExtraJson = "";
  static void Emit(string id, string section, string group, string kind, string en, string fr, string when, bool isLong, string note) {
    if (!First) Out.Append(",\n"); First = false;
    Out.Append("{\"id\":").Append(J(id)).Append(",\"section\":").Append(J(section)).Append(",\"group\":").Append(J(group))
      .Append(",\"kind\":").Append(J(kind)).Append(",\"en\":").Append(J(en)).Append(",\"fr\":").Append(J(fr))
      .Append(",\"when\":").Append(J(when)).Append(",\"long\":").Append(isLong ? "true" : "false")
      .Append(",\"note\":").Append(J(note)).Append(ExtraJson).Append("}");
    ExtraJson = "";
  }

  static LTable Resolve(object v) {
    if (v is LTable) return (LTable)v;
    var r = v as LRef;
    if (r != null && Cur.Locals.ContainsKey(r.Name)) return Cur.Locals[r.Name];
    return null;
  }

  static string Str(object v) { return v as string; }

  static string Num(object v) {
    if (v is double) return ((double)v).ToString(CultureInfo.InvariantCulture);
    return "?";
  }

  static string ListStr(object v) {
    var t = Resolve(v);
    if (t == null) return "?";
    var parts = new List<string>();
    foreach (var a in t.Arr) if (a is string) parts.Add((string)a);
    foreach (var kv in t.Map) if (kv.Key is string) parts.Add((string)kv.Key);
    return string.Join(", ", parts.ToArray());
  }

  static string When(object w) {
    var t = Resolve(w);
    if (t == null) return "";
    var parts = new List<string>();
    foreach (var kv in t.Map) {
      string k = kv.Key as string; object v = kv.Value;
      if (k == "night") parts.Add((v is bool && (bool)v) ? "night" : "daytime");
      else if (k == "indoors") parts.Add((v is bool && (bool)v) ? "indoors" : "outdoors");
      else if (k == "resting") parts.Add("city or inn");
      else if (k == "swimming") parts.Add("swimming");
      else if (k == "moving") parts.Add("walking");
      else if (k == "calm") parts.Add("no crowd around");
      else if (k == "alone") parts.Add("nobody in sight");
      else if (k == "fishFresh") parts.Add("just starting to fish");
      else if (k == "still") parts.Add("standing still");
      else if (k == "shifted") parts.Add((v is bool && (bool)v) ? "animal form" : "normal shape");
      else if (k == "form") parts.Add("form: " + Str(v) + (Str(v) == "furry" ? " (bear, cat, travel, ghost wolf)" : ""));
      else if (k == "cloak" || k == "boots" || k == "gloves" || k == "helm") parts.Add(((v is bool && (bool)v) ? "wearing " : "no ") + (k == "helm" ? "helmet" : k));
      else if (k == "intensityAbove") parts.Add("heavier than " + Num(v));
      else if (k == "intensityBelow") parts.Add("lighter than " + Num(v));
      else if (k == "armor") parts.Add("chest armor: " + Str(v));
      else if (k == "race") parts.Add("race: " + (v is string ? (string)v : ListStr(v)));
      else if (k == "notRace") parts.Add("not for: " + (v is string ? (string)v : ListStr(v)));
      else if (k == "npcRace") parts.Add("NPC race: " + (v is string ? (string)v : ListStr(v)));
      else if (k == "npcRole") parts.Add("NPC role: " + (v is string ? (string)v : ListStr(v)));
      else if (k == "npcSex") parts.Add("NPC: " + (Num(v) == "3" ? "female" : "male"));
      else if (k == "npcID") { var t2 = Resolve(v); parts.Add("only NPC " + (t2 != null ? string.Join("/", t2.Arr.ConvertAll(x => Num(x)).ToArray()) : Num(v))); }
      else if (k == "hungerBelow" || k == "thirstBelow" || k == "energyBelow") parts.Add(k.Replace("Below", "") + " below " + Num(v) + "%");
      else if (k == "crowd") parts.Add("crowd: " + (v is string ? (string)v : ListStr(v)));
      else if (k == "weather") parts.Add("weather: " + Str(v));
      else if (k == "airBelow") parts.Add("air below " + Num(v) + "°C");
      else if (k == "airAbove") parts.Add("air above " + Num(v) + "°C");
      else if (k == "notBiomes") parts.Add("not in: " + ListStr(v));
      else if (k == "subMatch") parts.Add("place name has: " + ListStr(v));
      else if (k != null) parts.Add(k);
    }
    return string.Join(" · ", parts.ToArray());
  }

  static string KindLabel(string k) {
    if (k == "arrive") return "first visit";
    if (k == "ambient") return "now and then";
    if (k == "hearth") return "hearthstone arrival";
    return k;
  }

  static string PlaceZone = null, PlaceBiome = null;
  static void Lines(string idPrefix, string section, string group, string kind, object list, string note) {
    var t = Resolve(list); if (t == null) return;
    int i = 0;
    foreach (var item in t.Arr) {
      i++;
      var line = Resolve(item); if (line == null) continue;
      var ex = new StringBuilder();
      if (PlaceZone != null) ex.Append(",\"zone\":").Append(J(PlaceZone));
      if (PlaceBiome != null) ex.Append(",\"biome\":").Append(J(PlaceBiome));
      if (line.Get("draft") is bool && (bool)line.Get("draft")) ex.Append(",\"draft\":true");
      if (Str(line.Get("check")) != null) ex.Append(",\"check\":").Append(J(Str(line.Get("check"))));
      var rw = Resolve(line.Get("rewrite"));
      if (rw != null) {
        ex.Append(",\"rewrite\":{\"en\":").Append(J(Str(rw.Get("en")))).Append(",\"fr\":").Append(J(Str(rw.Get("fr"))));
        if (rw.Get("when") != null) ex.Append(",\"when\":").Append(J(When(rw.Get("when"))));
        ex.Append("}");
      }
      ExtraJson = ex.ToString();
      Emit(idPrefix + ":" + i, section, group, kind, Str(line.Get("en")), Str(line.Get("fr")),
        When(line.Get("when")), line.Get("long") is bool && (bool)line.Get("long"), note);
    }
  }

  static void PlaceKinds(string idPrefix, string group, LTable place, string note) {
    foreach (var k in new[] { "arrive", "ambient", "hearth" }) {
      object v = place.Get(k);
      if (v != null) Lines(idPrefix + ":" + k, "Places", group, KindLabel(k), v, note);
    }
  }

  static string MomentGroup(string k) {
    if (k.StartsWith("firstTaste") || k.StartsWith("firstSip") || k.StartsWith("familiar") || k.EndsWith("Milestone") && (k.StartsWith("food") || k.StartsWith("drink"))
        || k.StartsWith("eat") || k.StartsWith("drink")) return "Meals and drinks";
    if (k.StartsWith("afterFight")) return "After a hard fight";
    if (k == "quiet") return "Quiet moment (said before a place line)";
    if (k == "herb" || k == "mine" || k == "skin" || k.StartsWith("herb_")) return "Gathering";
    if (k == "hearth" || k == "landing") return "Travel";
    if (k == "dawn" || k == "dusk") return "Dawn and dusk";
    if (k == "goIn" || k == "goOut") return "Stepping in and out";
    if (k == "bank" || k == "mail" || k == "auction" || k == "trainer") return "City errands";
    if (k.StartsWith("learn") || k.StartsWith("rank_") || k == "craftRankUp") return "Professions and recipes";
    if (k.StartsWith("loot") || k.StartsWith("craft")) return "Loot and crafting";
    if (k.StartsWith("revive")) return "Back to life";
    if (k == "discoveryMilestone") return "Discoveries";
    if (k.StartsWith("fall")) return "Falls";
    if (k.StartsWith("camp")) return "Campfires";
    if (k.StartsWith("questAccept_") || k.StartsWith("questDone_")) return "Quests";
    if (k == "npc") return "NPCs";
    if (k == "petRain") return "Pet in the rain";
    if (k.StartsWith("fish")) return "Fishing";
    return "Other";
  }

  static readonly HashSet<string> BodyKeys = new HashSet<string> { "coldEnter", "freezingEnter", "coldRemind", "freezingRemind",
    "warmBack", "hotEnter", "overheatEnter", "hotRemind", "overheatRemind", "coolBack", "soaked", "dry",
    "drinkRelief", "eatRelief", "restRelief", "fireWarm", "indoorsWarm" };

  static readonly string[] Bands = { "shy (new bond)", "friendly (40+)", "devoted (80+)" };

  public static string Run(string dir) {
    Out = new StringBuilder("[\n"); First = true;

    // Places (Senses)
    Cur = new LuaFile(Path.Combine(dir, "SensesData.lua"));
    var G = Cur.Globals;
    if (G.ContainsKey("S.generic")) Lines("senses:generic", "Places", "Anywhere", "now and then", G["S.generic"], null);
    if (G.ContainsKey("S.genericArrive")) Lines("senses:genericArrive", "Places", "Anywhere", "first visit", G["S.genericArrive"], null);
    if (G.ContainsKey("S.genericHearth")) Lines("senses:genericHearth", "Places", "Anywhere", "hearthstone arrival", G["S.genericHearth"], null);
    if (G.ContainsKey("S.weather")) Lines("senses:weather", "Places", "Weather", "now and then", G["S.weather"], "Rain, snow and sand are asleep until the game's weather types are confirmed.");
    if (G.ContainsKey("S.weatherChange"))
      foreach (var kv in G["S.weatherChange"].Map)
        Lines("senses:weatherChange:" + kv.Key, "Places", "Weather changes", kv.Key as string, kv.Value, null);
    if (G.ContainsKey("S.biomes"))
      foreach (var kv in G["S.biomes"].Map) {
        var b = Resolve(kv.Value); if (b == null) continue;
        PlaceBiome = kv.Key as string; PlaceKinds("senses:biome:" + kv.Key, "Landscape: " + kv.Key, b, null); PlaceBiome = null;
      }
    if (G.ContainsKey("S.zones"))
      foreach (var kv in G["S.zones"].Map) {
        var z = Resolve(kv.Value); if (z == null) continue;
        string id = kv.Key is double ? Num(kv.Key) : (kv.Key as string);
        string name = z.Comment != null ? z.Comment : id;
        PlaceZone = id; PlaceKinds("senses:zone:" + id, "Zone: " + name, z, null); PlaceZone = null;
      }
    if (G.ContainsKey("S.spots"))
      foreach (var item in G["S.spots"].Arr) {
        var sp = Resolve(item); if (sp == null) continue;
        var names = Resolve(sp.Get("names"));
        string nm = names != null ? (Str(names.Get("fr")) ?? Str(names.Get("en"))) : Str(sp.Get("id"));
        PlaceZone = Num(sp.Get("map")); PlaceKinds("senses:spot:" + Str(sp.Get("id")), "Spot: " + nm, sp, "Spot conditions: " + When(sp.Get("when"))); PlaceZone = null;
      }
    if (G.ContainsKey("S.subzones"))
      foreach (var item in G["S.subzones"].Arr) {
        var sz = Resolve(item); if (sz == null) continue;
        var names = Resolve(sz.Get("names"));
        string nm = names != null && names.Arr.Count > 0 ? ListStr(names) : Str(sz.Get("id"));
        PlaceZone = sz.Get("zone") != null ? Num(sz.Get("zone")) : null; PlaceKinds("senses:sub:" + Str(sz.Get("id")), "Place: " + nm, sz, sz.Comment); PlaceZone = null;
      }

    // Moments
    Cur = new LuaFile(Path.Combine(dir, "MomentsData.lua"));
    G = Cur.Globals;
    if (G.ContainsKey("D.MOMENTS"))
      foreach (var kv in G["D.MOMENTS"].Map) {
        string k = kv.Key as string; if (k == null) continue;
        Lines("moment:" + k, "Moments", MomentGroup(k), k, kv.Value, null);
      }
    // pools added later in the file: D.MOMENTS.herb_peacebloom = { ... }
    foreach (var kv in G) {
      if (!kv.Key.StartsWith("D.MOMENTS.")) continue;
      string k = kv.Key.Substring(10);
      Lines("moment:" + k, "Moments", MomentGroup(k), k, kv.Value, null);
    }
    // NPC lines kept in local lists (NPC_MORE...) and added to D.MOMENTS.npc in a loop
    foreach (var kv in Cur.Locals) {
      if (!kv.Key.StartsWith("NPC_")) continue;
      Lines("moment:npc:" + kv.Key, "Moments", "NPCs", "npc", kv.Value, null);
    }
    foreach (var pair in new[] { new[] { "D.BIRTH_RACE", "race" }, new[] { "D.BIRTH_CLASS", "class" } }) {
      if (!G.ContainsKey(pair[0])) continue;
      foreach (var kv in G[pair[0]].Map) {
        var line = Resolve(kv.Value); if (line == null) continue;
        Emit("birth:" + pair[1] + ":" + kv.Key, "Moments", "New character", pair[1] + ": " + kv.Key,
          Str(line.Get("en")), Str(line.Get("fr")), "", false, "The race part comes first, then the class part.");
      }
    }

    // Body lines with gear / shape conditions (each line once, with the moments that use it)
    if (G.ContainsKey("D.BODY_LINES")) {
      var used = new Dictionary<string, List<string>>();
      var order = new List<string>();
      foreach (var kv in G["D.BODY_LINES"].Map) {
        var list = kv.Value as LTable; if (list == null) continue;
        foreach (var item in list.Arr) {
          var r = item as LRef; if (r == null) continue;
          if (!used.ContainsKey(r.Name)) { used[r.Name] = new List<string>(); order.Add(r.Name); }
          used[r.Name].Add(kv.Key as string);
        }
      }
      foreach (var name in order) {
        LTable line; if (!Cur.Locals.TryGetValue(name, out line)) continue;
        var ex = new StringBuilder();
        if (line.Get("draft") is bool && (bool)line.Get("draft")) ex.Append(",\"draft\":true");
        ExtraJson = ex.ToString();
        Emit("bodyline:" + name, "Body", "Gear, forms, needs and naps", "used for: " + string.Join(", ", used[name].ToArray()),
          Str(line.Get("en")), Str(line.Get("fr")), When(line.Get("when")), false,
          "Replaces the usual line some of the time when it fits (always in an animal form). Items show as links in game.");
      }
    }

    // Pet, body and danger lines (Locale pools)
    var en = new LuaFile(Path.Combine(dir, "Locale.lua"));
    var fr = new LuaFile(Path.Combine(dir, "Locale_frFR.lua"));
    foreach (var kv in en.Globals) {
      if (!kv.Key.StartsWith("M.")) continue;
      string key = kv.Key.Substring(2);
      LTable frT; fr.Globals.TryGetValue(kv.Key, out frT);
      string baseKey = key, variant = "";
      foreach (var v in new[] { "_bird", "_scaly", "_chitin" })
        if (key.EndsWith(v)) { baseKey = key.Substring(0, key.Length - v.Length); variant = v.Substring(1); }
      string section = BodyKeys.Contains(key) || key.StartsWith("body_") ? "Body"
        : (key.StartsWith("danger") ? "Places" : "Pet");
      string group = section == "Places" ? "Danger feelings" : baseKey;
      string kind = section == "Places" ? key : (variant != "" ? variant + " pets" : "");
      var enT = kv.Value;
      bool banded = enT.Arr.Count > 0 && enT.Arr[0] is LTable;
      if (banded) {
        for (int b = 0; b < enT.Arr.Count; b++) {
          var eb = enT.Arr[b] as LTable; if (eb == null) continue;
          LTable fb = frT != null && b < frT.Arr.Count ? frT.Arr[b] as LTable : null;
          for (int i = 0; i < eb.Arr.Count; i++) {
            string bl = b < Bands.Length ? Bands[b] : ("stage " + (b + 1));
            Emit("pool:" + key + ":" + (b + 1) + ":" + (i + 1), section, group, (kind != "" ? kind + " · " : "") + bl,
              Str(eb.Arr[i]), fb != null && i < fb.Arr.Count ? Str(fb.Arr[i]) : null, "", false, null);
          }
        }
      } else {
        for (int i = 0; i < enT.Arr.Count; i++) {
          if (!(enT.Arr[i] is string)) continue;
          Emit("pool:" + key + ":" + (i + 1), section, group, kind,
            Str(enT.Arr[i]), frT != null && i < frT.Arr.Count ? Str(frT.Arr[i]) : null, "", false, null);
        }
      }
    }

    Out.Append("\n]");
    var w = new LuaFile(Path.Combine(dir, "World.lua"));
    var zs = new StringBuilder("[");
    bool firstZ = true;
    if (w.Globals.ContainsKey("D.CLIMATE"))
      foreach (var kv in w.Globals["D.CLIMATE"].Map) {
        var z = kv.Value as LTable; if (z == null) continue;
        string zid = Num(kv.Key);
        string nm = null; int line = 0;
        // the zone name is the comment at the end of its line
        foreach (var t in w.Toks) if (t.Type == "N" && t.Text == zid) { line = t.Line; break; }
        string cm; if (w.Comments.TryGetValue(line, out cm)) nm = cm.Split(new[] { ":" }, StringSplitOptions.None)[0].Trim();
        if (!firstZ) zs.Append(","); firstZ = false;
        zs.Append("{\"id\":").Append(J(zid)).Append(",\"name\":").Append(J(nm ?? zid)).Append(",\"biome\":").Append(J(Str(z.Get("biome")))).Append("}");
      }
    zs.Append("]");
    return "{\"zones\":" + zs.ToString() + ",\"lines\":" + Out.ToString() + "}";
  }
}
