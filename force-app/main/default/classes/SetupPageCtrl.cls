public with sharing class SetupPageCtrl extends SetupCtrl {
   
    public SetupExtractApi setupExtractApi { get; set; }


    // CONSTRUCTOR

    public SetupPageCtrl() {
        setupExtractApi = new SetupExtractApi();
    }


    // PUBLIC

    public override List<SetupStep> steps() {
        return new List<SetupStep>{ setupExtractApi };
    }
}