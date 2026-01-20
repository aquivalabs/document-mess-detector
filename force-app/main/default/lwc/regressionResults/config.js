const COLUMNS = [
    {
        label: 'Rule',
        fieldName: 'ruleUrl',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'ruleName' },
            target: '_blank',
        },
    },
    { label: 'Expected', fieldName: 'expected' },
    { label: 'Fail', fieldName: 'failed', type: 'number' },
    {
        label: 'Succes',
        fieldName: 'succeeded',
        type: 'number',
    },
    { label: 'Unsure', fieldName: 'unsure', type: 'number' },
    { label: 'Accuracy', fieldName: 'accuracy', type: 'percent' },
];

export { COLUMNS };
