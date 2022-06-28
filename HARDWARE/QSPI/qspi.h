#ifndef __QSPI_H
#define __QSPI_H
#include "stm32h7xx.h"
#include "stdint-gcc.h"
//////////////////////////////////////////////////////////////////////////////////	 
   
/**********************************************************************/

//QSPI驱动代码	

//STM32H7工程模板-HAL库函数版本
//DevEBox  大越创新
//淘宝店铺：mcudev.taobao.com
//淘宝店铺：shop389957290.taobao.com	
  
/**********************************************************************/					  
////////////////////////////////////////////////////////////////////////////////// 	
/* Private define ------------------------------------------------------------*/
/*命令定义-开头*******************************/

/** 
  * @brief  W25Q256JV 指令  
  */  
/* 复位操作 */
#define RESET_ENABLE_CMD                     0x66
#define RESET_MEMORY_CMD                     0x99

#define ENTER_QPI_MODE_CMD                   0x38
#define EXIT_QPI_MODE_CMD                    0xFF

/* 识别操作 */
#define READ_ID_CMD                          0x90
#define DUAL_READ_ID_CMD                     0x92
#define QUAD_READ_ID_CMD                     0x94
#define READ_JEDEC_ID_CMD                    0x9F

/* 读操作 */
#define READ_CMD                             0x03
//#define FAST_READ_CMD                        0x0B
//#define DUAL_OUT_FAST_READ_CMD               0x3B
//#define DUAL_INOUT_FAST_READ_CMD             0xBB
#define QUAD_OUT_FAST_READ_CMD               0x6B
#define QUAD_INOUT_FAST_READ_CMD             0xEB
#define QUAD_INOUT_4BYTE_FAST_READ_CMD       0xEC

/* 写操作 */
#define WRITE_ENABLE_CMD                     0x06
#define WRITE_DISABLE_CMD                    0x04

/* 寄存器操作 */
#define READ_STATUS_REG1_CMD                  0x05
#define READ_STATUS_REG2_CMD                  0x35
#define READ_STATUS_REG3_CMD                  0x15

#define WRITE_STATUS_REG1_CMD                 0x01
#define WRITE_STATUS_REG2_CMD                 0x31
#define WRITE_STATUS_REG3_CMD                 0x11


/* 编程操作 */
#define PAGE_PROG_CMD                        0x12
#define QUAD_INPUT_PAGE_PROG_CMD             0x32
//#define EXT_QUAD_IN_FAST_PROG_CMD            0x12

/* 擦除操作 */
#define SECTOR_ERASE_CMD                     0x21
#define CHIP_ERASE_CMD                       0xC7

//#define PROG_ERASE_RESUME_CMD                0x7A
//#define PROG_ERASE_SUSPEND_CMD               0x75

#define ENTER_4_BYTE_ADDR_MODE_CMD					 0xB7
#define EXIT_4_BYTE_ADDR_MODE_CMD					 	 0xE9

/* 状态寄存器标志 */
#define W25Q256JV_FSR_BUSY                    ((uint16_t)0x0101)    /*!< busy */
#define W25Q256JV_FSR_WREN                    ((uint16_t)0x0202)    /*!< write enable */
#define W25Q256JV_FSR_QE                      ((uint8_t)0x06)    /*!< quad enable */
/*命令定义-结尾*******************************/
//===================================================================================
extern QSPI_HandleTypeDef QSPI_Handler;    //QSPI句柄

uint8_t QSPI_Init(void);												//初始化QSPI
void QSPI_Send_CMD(uint8_t cmd,uint32_t addr,uint8_t mode,uint8_t dmcycle);			//QSPI发送命令
uint8_t QSPI_Receive(uint8_t* buf,uint32_t datalen);							//QSPI接收数据
uint8_t QSPI_Transmit(uint8_t* buf,uint32_t datalen);							//QSPI发送数据

//memmap
uint8_t QSPI_MemMap_Init(void);
#endif


















/**********************************************************************/

//QSPI驱动代码	

//STM32H7工程模板-HAL库函数版本
//DevEBox  大越创新
//淘宝店铺：mcudev.taobao.com
//淘宝店铺：shop389957290.taobao.com	
  
/**********************************************************************/	


