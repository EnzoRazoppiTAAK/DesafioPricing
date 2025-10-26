public with sharing class ClassThatDependsOnA {
    

    public void methodA(){
        ClassA_Service classA_Service = new ClassA_Service();
        classA_Service.methodA();

        //ClassA_Service nao deve ter um metodo B que essa classe nao chama mas outra chama
    }
}