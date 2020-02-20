_setup(){
echo "hello from $(pwd)"
echo "int main(){}"> hello.c
}
_build(){
echo "example build for hello.c"
gcc -o hello hello.c
}
_install(){
echo "example install"
}
