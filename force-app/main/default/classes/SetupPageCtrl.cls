public with sharing class SetupPageCtrl extends SetupCtrl {
   
    public SetupOpenAi setupOpenAi { get; set; }
    public SetupExtractApi setupExtractApi { get; set; }


    // CONSTRUCTOR

    public SetupPageCtrl() {
        setupOpenAi = new SetupOpenAi();
        setupExtractApi = new SetupExtractApi();
    }


    // PUBLIC

    public override List<SetupStep> steps() {
        return new List<SetupStep>{ setupOpenAi, setupExtractApi };
    }
}