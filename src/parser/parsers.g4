parser grammar parsers;

options {
    tokenVocab= lexers;
    language= Cpp;
}

program: statement* EOF;

statement:
    expression ';'                           # expressionStatement
    | 'extern' functionSignature ';'         # externalFunction
    | 'def' functionSignature expression ';' # functionDefinition
    ;

expression:
    Number                                                    # literalExpression
    | Identifier                                              # idExpression
    | Identifier '(' expressionList? ')'                      # callExpression
    | '(' expression ')'                                      # parenthesesExpression
    | expression op= ('*' | '/') expression                   # multiplicativeExpression
    | expression op= ('+' | '-') expression                   # additiveExpression
    | expression op= ('<' | '>' | '<=' | '>=') expression     # relationalExpression
    | expression op= ('==' | '!=') expression                 # equalityExpression
    | <assoc= right> expression '?' expression ':' expression # conditionalExpression
    ;

expressionList: expression (',' expression)*;

argumentList: Identifier (',' Identifier)*;

functionSignature: Identifier '(' argumentList? ')';
