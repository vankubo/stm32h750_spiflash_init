#include "stm32h7xx.h"
#include "bsp_led.h"
#include "sys_conf.h"
#include "sys_delay.h"
#include "sys_usart.h"
#include "norflash.h"

uint8_t testdat[128];


int main()
{
    uint32_t sysclock = 0; 
    uint32_t i,j;

    /* 系统时钟初始化成480MHz */
	SystemClock_Config();
    HAL_InitTick(0);
     SCB_EnableICache();    // 使能指令 Cache
//  SCB_EnableDCache();    // 使能数据 Cache
    DEBUG_USART_Config();
    /* LED 端口初始化 */
	LED_GPIO_Config();
    
    sysclock = HAL_RCC_GetSysClockFreq();
    printf("stm32h750 run at %dMHz\n",sysclock/1000000);
   
#if 1
 //QSPI
    NORFLASH_Init();				//NORFLASH(W25Q64)初始化
	printf("flash init done\n");
	
	while(NORFLASH_ReadID()!=W25Q64)							//检测不到W25Q64
	{
		printf("W25Q64 Check Failed!\n");
		HAL_Delay(500);
		printf("Please Check!\n");
		HAL_Delay(500);
	}

	printf("W25Q64 id:0x%X\n",NORFLASH_ReadID());
    //qspi test
    /*
    for(i=0;i<128;i++)
    {
        testdat[i]=i%0xff;
    }
    NORFLASH_Write((uint8_t*)testdat,0,128);		//第0个地址处开始,写入SIZE长度的数据
    for(i=0;i<128;i++)
    {
        testdat[i]=0x00;
    }
    */
    NORFLASH_Read((uint8_t*)testdat,0,128);
    for(i=0;i<128/8;i++)
    {
        for(j=0;j<8;j++)
        {
            printf("0x%X ",testdat[i*8+j]);
        }
        printf("\n");
    }
    printf("----------------\n");
#endif

#if 0
    //内存映射测试
    uint8_t addr=0X90000000;
    printf("qspi mem map init:%d\n",QSPI_MemMap_Init());    
#endif

    while(1)
    {
        HAL_Delay(500);
        LED1_TOGGLE;
        

    }
    return 0;
}
