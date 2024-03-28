

int main()
{
    while (1)
    {
        
    }
    return 0;
}

/*
    The idea is:
    Have a lot of sprites and with the register connected with the VGA_TOP, 
    sending to the VGA_BASIC_ROM what image we will show
*/
main_menu()
{
    MY_VGA.Background = 0x00000001; // at this moment I have one condition in 
    //VGA_Basic_ROM where compare if the register is one, if yes show the main 
    //screen
    

}
