import { LightningElement, wire } from 'lwc';
import searchForAllFAQs from '@salesforce/apex/ApexClassToHelpLWC.searchForAllFAQs';

export default class FAQ extends LightningElement {

    fAQslist = [];
    fAQsFilteredlist = [];
    allFAQs = [];

    firstQuestion;
    firstAnswer;
    secondQuestion;
    secondAnswer;

    pageNumbersInitial;
    pageNumbers;

    typedValue = '';

    @wire(searchForAllFAQs) FAQs({ data, error }) {

        if (data) {
            this.fAQslist = [...data];

            if(data.length > 10){
                this.fAQslist = this.fAQslist.splice(0, 10);

                if(data.length%10 === 0){
                    this.pageNumbersInitial = data.length/10;
                }else{
                    this.pageNumbersInitial = Math.floor(data.length/10) + 1;
                }
            }

            this.calculateArrayPageNumbersInitial();
            this.allFAQs = [...data];

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
            this.suportArray = [... this.allFAQs];
            this.fAQslist = this.suportArray.splice(0, 10);
            this.calculateArrayPageNumbersInitial();
        }else{
            this.suportArray = [... this.allFAQs];
            this.fAQsFilteredlist = this.allFAQs.filter(faq => faq.Question__c.toLowerCase().includes(this.typedValue));
            this.fAQslist = this.fAQsFilteredlist.slice(0, 10);
            this.calculateArrayPageNumbersAfterFilter(this.fAQsFilteredlist);
        }
    }

    calculateArrayPageNumbersInitial(){
        this.arrayPageNumbers = [];

        for(let i = 1; i <= this.pageNumbersInitial; i++){
            this.arrayPageNumbers.push({number: i, type: "original"});
        }
    }

    calculateArrayPageNumbersAfterFilter(fAQsFilteredlist){
        this.arrayPageNumbers = [];
        // console.log(fAQsFilteredlist);
        // console.log('AQUi3');


        if(fAQsFilteredlist.length > 10){

            if(fAQsFilteredlist.length%10 === 0){
                this.pageNumbers = fAQsFilteredlist.length/10;
            }else{
                this.pageNumbers = Math.floor(fAQsFilteredlist.length/10) + 1;
            }

            for(let i = 1; i <= this.pageNumbers; i++){
                this.arrayPageNumbers.push({number: i, type: "filtered"});
            }

        }else{
            this.arrayPageNumbers.push({number: 1, type: "filtered"});
        }
    }

    
    changePage(event){

        let desiredPage = Number(event.currentTarget.dataset.number);
        let typePage = event.currentTarget.dataset.type;

        if(typePage === "filtered"){

            this.suportArray = [... this.fAQsFilteredlist];
            console.log(this.suportArray);
            console.log(desiredPage);
            console.log(typePage);
            this.fAQslist = this.suportArray.slice((desiredPage-1)*10, (desiredPage-1)*10 + 10);

        }else if(typePage === "original"){

            this.suportArray = [... this.allFAQs];
            this.fAQslist = this.suportArray.splice((desiredPage-1)*10, 10);
        }
    }
}