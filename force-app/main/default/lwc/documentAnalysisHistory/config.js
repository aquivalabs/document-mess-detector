const COLUMNS = [
    {
        label: 'Analysis',
        fieldName: 'analysisUrl',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'analysisName' },
            target: '_blank',
        },
    },
    {
        label: 'Ruleset',
        fieldName: 'rulesetUrl',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'rulesetName' },
            target: '_blank',
        },
    },
    { label: 'Created By', fieldName: 'createdBy' },
    {
        label: 'Created Date',
        fieldName: 'createdDate',
        type: 'date',
        typeAttributes: {
            year: 'numeric',
            month: 'short',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
        },
    },
    { label: 'Status', fieldName: 'status' },
];

export { COLUMNS };
