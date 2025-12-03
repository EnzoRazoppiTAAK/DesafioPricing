import { LightningElement, wire } from 'lwc';
import searchForAllFAQs from '@salesforce/apex/ApexClassToHelpLWC.searchForAllFAQs';

export default class FAQ extends LightningElement {

    fAQslist = [];
    allFAQs = [];

    firstQuestion;
    firstAnswer;
    secondQuestion;
    secondAnswer;

    typedValue = '';

    @wire(searchForAllFAQs) FAQs({ data, error }) {
        if (data) {
            this.fAQslist = data;
            this.allFAQs = data;
        } else if (error) {
            this.fAQslist = undefined;
        }
    }
    
    timeoutId;
    
    handleInput(event){

        this.typedValue = event.target.value.toLowerCase();

        clearTimeout(this.timeoutId);

        timeoutId = setTimeout(() => {
            this.filterFAQs()
        }, 1000);
    }

    filterFAQs() {
        
        if(this.typedValue === ''){
            this.fAQslist = this.allFAQs;
        }else{
            this.fAQslist = this.allFAQs.filter(faq => faq.Question__c.toLowerCase().includes(this.typedValue));
        }
    }
}