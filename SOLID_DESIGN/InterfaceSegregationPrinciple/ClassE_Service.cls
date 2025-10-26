public with sharing class ClassE_Service implements MethodA_Interface, MethodB_Interface{

    public void methodA(){
        Type methodAInterfaceType = Type.forName('ClassA_Service');
        MethodA_Interface methodAInterface = (MethodA_Interface) methodAInterfaceType.newInstance();
        methodAInterface.methodA(); //classeE nao sabe nada da classe A porque ele compila em runtime
    }


    public void methodB(){
        ClassB_Service classB_service = new ClassB_Service();
        classB_service.methodB();
    }
    
}