state("SKALD Against the Black Priory")
{
}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
}
init
{
    vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
    {
        var mainControl = mono["SKALDAssembly", "MainControl"];
        var stateControl = mono["SKALDAssembly", "StateControl"];
        var dataControl = mono["SKALDAssembly", "DataControl"];
        var achievementControl = mono["SKALDAssembly", "AchievementControl"];
        
        var questControl = mono["SKALDAssembly", "QuestControl"];
        var quest = mono["SKALDAssembly", "Quest"];
        var achievements = mono["SKALDAssembly", "SkaldBaseList"];
        var coreData = mono["SKALDAssembly", "CoreData"];
        var baseObject = mono["SKALDAssembly", "SkaldBaseObject"];

        vars.Helper["name"] =
            mono.MakeString(mainControl, "gameControl", "dataControl", "currentMap", "coreData", "id");
        vars.Helper["gameStarted"] = mono.Make<bool>(mainControl, "gameControl", "dataControl", "gameStarted");

        vars.Helper["questNameRefugees"] = mono.MakeString(mainControl, "gameControl", "dataControl", "questControl",
            "questList", 0x18, 0x5A0, quest["coreData"], coreData["id"]);
        vars.Helper["questNameRetakeHorryn"] = mono.MakeString(mainControl, "gameControl", "dataControl",
            "questControl", "questList", 0x18, 0x720, quest["coreData"], coreData["id"]);
        vars.Helper["questNameStormingKeep"] = mono.MakeString(mainControl, "gameControl", "dataControl",
            "questControl", "questList", 0x18, 0x738, quest["coreData"], coreData["id"]);
        vars.Helper["questNamePlat"] = mono.MakeString(mainControl, "gameControl", "dataControl", "questControl",
            "questList", 0x18, 0x708, quest["coreData"], coreData["id"]);
        vars.Helper["questNameToSleepAndDream"] = mono.MakeString(mainControl, "gameControl", "dataControl",
            "questControl", "questList", 0x18, 0x7C8, quest["coreData"], coreData["id"]);
        vars.Helper["questNameUntoldEons"] = mono.MakeString(mainControl, "gameControl", "dataControl", "questControl",
            "questList", 0x18, 0x798, quest["coreData"], coreData["id"]);
        vars.Helper["questNameFinal"] = mono.MakeString(mainControl, "gameControl", "dataControl", "questControl",
            "questList", 0x18, 0x6D8, quest["coreData"], coreData["id"]);

        vars.Helper["questIntroVilla"] = mono.Make<bool>(mainControl, "gameControl", "dataControl", "questControl",
            "questList", 0x18, 0x570, quest["completed"]);
        vars.Helper["questRefugees"] = mono.Make<bool>(mainControl, "gameControl", "dataControl", "questControl",
            "questList", 0x18, 0x5A0, quest["completed"]);
        vars.Helper["questRetakeHorryn"] = mono.Make<bool>(mainControl, "gameControl", "dataControl", "questControl",
            "questList", 0x18, 0x720, quest["completed"]);
        vars.Helper["questSecretTunnel"] = mono.Make<bool>(mainControl, "gameControl", "dataControl", "questControl",
            "questList", 0x18, 0x750, quest["completed"]);
        vars.Helper["questStormingKeep"] = mono.Make<bool>(mainControl, "gameControl", "dataControl", "questControl",
            "questList", 0x18, 0x738, quest["completed"]);
        vars.Helper["questBlackSeas"] = mono.Make<bool>(mainControl, "gameControl", "dataControl", "questControl",
            "questList", 0x18, 0x7E0, quest["completed"]);
        vars.Helper["questPlateauOfMadness"] = mono.Make<bool>(mainControl, "gameControl", "dataControl",
            "questControl", "questList", 0x18, 0x708, quest["completed"]);
        vars.Helper["questToSleepAndDream"] = mono.Make<bool>(mainControl, "gameControl", "dataControl", "questControl",
            "questList", 0x18, 0x7C8, quest["completed"]);
        vars.Helper["questUntoldEons"] = mono.Make<bool>(mainControl, "gameControl", "dataControl", "questControl",
            "questList", 0x18, 0x798, quest["completed"]);


        vars.Helper["achievements"] = mono.MakeList<IntPtr>(mainControl, "gameControl", "dataControl",
            "achievementControl", "achievements", achievements["objectList"]);


        if (vars.Helper["name"] == null)
        {
            return false;
        }

        if (vars.Helper["questIntroVilla"] == null)
        {
            return false;
        }

        return true;
    });
    vars.Helper.Load();
}
update{

}

isLoading
{
    return false;
}

split {
    if (current.questIntroVilla && !old.questIntroVilla)
    {
        //prologue is completed.
        return true;
    }

    if (current.name != old.name)
    {
        if (current.name == "MAP_IdraCostalPass" || old.name == "MAP_IdraCostalPass")
        {
            //coastal pass is started/completed.
            return true;
        }
    }

    if (current.questRefugees && !old.questRefugees)
    {
        //refugee quest is completed.
        return true;
    }

    if (current.questRetakeHorryn && !old.questRetakeHorryn)
    {
        //reavers are dead.
        return true;
    }

    if (current.questSecretTunnel && !old.questSecretTunnel)
    {
        //the keep has been infiltrated.
        return true;
    }

    if (current.questStormingKeep && !old.questStormingKeep)
    {
        //the keep has been secured.
        return true;
    }

    if (current.questBlackSeas && !old.questBlackSeas)
    {
        //we have sailed to gradla.
        return true;
    }

    if (current.questPlateauOfMadness && !old.questPlateauOfMadness)
    {
        //we have defeated the queen and made it onto the plateau.
        return true;
    }

    if (current.questToSleepAndDream && !old.questToSleepAndDream)
    {
        //we have made it through the priory to the excavation site.
        return true;
    }

    if (current.questUntoldEons && !old.questUntoldEons)
    {
        //we have defeated the final boss and entered the epilogue
        return true;
    }

    if (current.name == "MAP_PrioryVault" && current.achievements.Count != old.achievements.Count)
    {
        int gameWinAchievement = -1;
        //this check is brutal so we only want to do it when on the final map of the game.
        for (int i = 0; i < current.achievements.Count; i++)
        {
            IntPtr coreData = vars.Helper.Read<IntPtr>(current.achievements[i] + 0x10);
            string id = vars.Helper.ReadString(coreData + 0x10);
            if (id == "ACH_AllIsDarkness")
            {
                return true;
            }
        }
    }
}

start
{
    if (old.gameStarted == current.gameStarted)
        return;

    return current.gameStarted;
}