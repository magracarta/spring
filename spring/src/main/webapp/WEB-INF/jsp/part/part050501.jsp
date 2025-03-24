<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 재고관리 > 재고조정요청현황 > 재고조정요청서등록 > null
-- 작성자 : 박준영
-- 최초 작성일 : 2020-08-10 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
   <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
   <script type="text/javascript">
   
      var partCnt = 0;
      var partName = '';
      var partAdjustJson = JSON.parse('${codeMapJsonObj['PART_ADJUST']}');      //부품조정사유
      
      $(document).ready(function() {
         // 그리드 생성
         createAUIGrid();      
         
         if(${page.add.AVG_PRICE_SHOW_YN ne 'Y'}) {
            //평균매입가는 권한있는 사람만 보여줌
            var hideList = ["sale_price", "sale_amt","buy_price","buy_amt"];
            AUIGrid.hideColumnByDataField(auiGrid, hideList);
            $("#avg_price_sum").hide();
         }
      
      });
      
      
      // 그리드생성
      function createAUIGrid() {
         var gridPros = {
            rowIdField : "_$uid",
            showRowNumColumn: true,
            showStateColumn : true,
            editableOnFixedCell : true,
            editable : true
         };
         // AUIGrid 칼럼 설정
         var columnLayout = [
            {
                headerText: "부품번호",
                dataField: "part_no",
                width: "10%",
               style : "aui-center aui-editable",
               editRenderer : {            
                  type : "ConditionRenderer", 
                  conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
                     var param = {
                        s_search_kind : 'DEFAULT_PART',
                        's_warehouse_cd' : $M.getValue("warehouse_cd"),
                        's_only_warehouse_yn' : "N",   // 센터일 때만 Y로 넘김 -> 전체 다 나오게 변경
                         's_not_sale_yn' : "Y",      // 매출정지 제외
                         's_not_in_yn' : "Y",         // 미수입 제외
                         's_part_mng_cd' : ""
                     };
                     return fnGetPartSearchRenderer(dataField, param);
                  },
               },
               
            },
            {
               headerText : "부품명",
               dataField : "part_name",
                width: "10%",
               style : "aui-left",
               editable : false,
            },
            {
                headerText: "저장위치",
                dataField: "storage_name",
                width: "10%",
               style : "aui-center",
               editable : false,
            },
            {
                headerText: "센터재고",
                dataField: "current_stock",
               style : "aui-center",
                dataType : "numeric",
                formatString : "#,##0",
                width : "8%",
               editable : false,
            },
            {
                headerText: "실사수량",
                dataField: "check_stock",
                style : "aui-center",
                dataType : "numeric",
                formatString : "#,##0",
                width : "8%",
               required : true
            },
            {
                headerText: "차이수량",
                dataField: "diff_cnt",
                style : "aui-center",
                dataType : "numeric",
                formatString : "#,##0",
                width : "8%",
               editable : false,
               required : true
            },
            {
                
                dataField: "diff_amt",
                visible : false
            },
            {
                headerText: "사유",
                dataField: "remark",
                width: "20%",
               style : "aui-left",
               editable : true,
               editRenderer : {
                     type : "InputEditRenderer",
                     maxlength : 100,
                     // 에디팅 유효성 검사
                     validator : AUIGrid.commonValidator
               }
            },
            {
                headerText: "소비자가",
                dataField: "sale_price",
               style : "aui-right",
                dataType : "numeric",
                formatString : "#,##0",
                visible : true,
               editable : false,
            },
            {
                headerText: "금액",
                dataField: "sale_amt",
               style : "aui-right",
                dataType : "numeric",
                formatString : "#,##0",
                visible : true,
               editable : false,
            },
            {
                headerText: "평균매입가",
                dataField: "buy_price",
               style : "aui-right",
                dataType : "numeric",
                formatString : "#,##0",
                visible : true,
               editable : false,
            },
            {
                headerText: "금액",
                dataField: "buy_amt",
               style : "aui-right",
                dataType : "numeric",
                formatString : "#,##0",
                visible : true,
               editable : false,
            },
            
            {
                headerText: "승인코드",
                dataField: "part_adjust_cd",
                width: "8%",
                style : "aui-center",
               editRenderer : {
                  type : "DropDownListRenderer",
                  showEditorBtn : false,
                  showEditorBtnOver : false,
                  list : partAdjustJson,
                  keyField : "code_value", 
                  valueField : "code_name"             
               },
               labelFunction : function(rowIndex, columnIndex, value){
                  for(var i=0; i<partAdjustJson.length; i++){
                     if(value == partAdjustJson[i].code_value){
                        return partAdjustJson[i].code_name;
                     }
                     else if(value == "") {

                        AUIGrid.updateRow(auiGrid, { "part_adjust_cd" : partAdjustJson[0].code_value }, rowIndex);
                        
                        return partAdjustJson[0].code_name;
                        break;
                     }
                  }
                  return value;
               }
               
               
            },
            {
                headerText: "실사참조자료키",
                dataField: "part_check_stock_seq",
                width: "10%",
               style : "aui-center",
               editable : false,
            },
            {
               
               headerText : "삭제",
               renderer : {
                  type : "ButtonRenderer",
                  onClick : function(event) {
                      var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
                     if (isRemoved == false) {
                        AUIGrid.removeRow(event.pid, event.rowIndex);      
                     } else {
                        AUIGrid.restoreSoftRows(auiGrid, "selectedIndex"); 
                     } 
                  }
               },
               labelFunction : function(rowIndex, columnIndex, value,
                     headerText, item) {
                  return '삭제'
               },
      
               style : "aui-center",
               editable : false
            },
         ];
         

         // 그리드 출력
         auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
         // 그리드 갱신
         AUIGrid.setGridData(auiGrid, []);
         // AUIGrid.setFixedColumnCount(auiGrid, 2);
         // 에디팅 시작 이벤트 바인딩
         AUIGrid.bind(auiGrid, "cellEditBegin", auiCellEditHandler);
         // 에디팅 정상 종료전 이벤트 바인딩
         AUIGrid.bind(auiGrid, "cellEditEndBefore", auiCellEditHandler);
         // 에디팅 정상 종료 이벤트 바인딩
         AUIGrid.bind(auiGrid, "cellEditEnd", auiCellEditHandler);
         // 에디팅 취소 이벤트 바인딩
         AUIGrid.bind(auiGrid, "cellEditCancel", auiCellEditHandler);
         
         $("#auiGrid").resize();

      }
      
      // 편집 핸들러 (부품)
      function auiCellEditHandler(event) {
         switch(event.type) {
         case "cellEditEndBefore" :
            if(event.dataField == "part_no") {
               var isUnique = AUIGrid.isUniqueValue(auiGrid, event.dataField, event.value);   
               if (isUnique == false && event.value != "") {
                  setTimeout(function() {
                        AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "부품번호가 중복됩니다.");
                  }, 1);
                  return "";
               } else {
                  if (event.value == "") {
                     return event.oldValue;                     
                  }
               }
            }
            
            break;
            case "cellEditBegin" :      
               
               //재고실사참조로 가져온 값은 수정 불가
               if(event.item.part_check_stock_seq != ""){
                  return false;
               }   
               
               if(event.dataField == "remark") {
                                       
                  // 차이수량이 0아닌 경우에만 에디팅허용         
                  if(event.item.diff_cnt != 0) {
                     return true;
                  } else {
                     return false; 
                  }                  
               }   
      
            break;            
            case "cellEditEnd" :
               if(event.dataField == "part_no") {
                  if (event.value == ""){
                     return "";
                  }
                  // remote renderer 에서 선택한 값
                  var item = fnGetPartItem(event.value);

                     if(item === undefined) {
                        AUIGrid.updateRow(auiGrid, {part_no : event.oldValue}, event.rowIndex);
                     } else {
                        // 수정 완료하면, 나머지 필드도 같이 업데이트 함.
                        // 차이수량은 자동계산되게 처리
                        AUIGrid.updateRow(auiGrid, {
                           part_name : item.part_name,
                           storage_name :  item.storage_name, 
                           sale_price : item.sale_price,
                           sale_amt : "0",
                           current_stock : item.part_warehouse_current,
                           diff_cnt : 0 - item.part_warehouse_current,
                           diff_amt : item.sale_price * (  0 - item.part_warehouse_current ),
                           buy_price : "0",   
                           buy_amt :  "0",      
                           part_check_stock_seq : "",
                           part_adjust_cd : 10
                        }, event.rowIndex);
                     } 
                  
                }
               
                     
               //조사수량  변경하기         
               if(event.dataField == "check_stock") {
                  
                  //변경값 - 원래값 
                  var checkStockValue = event.value - event.oldValue;
                  
                  //수량이 변결될때만
                  if ( event.value != event.oldValue ) {         
                     // 차이수량 갱신
                        AUIGrid.updateRow(auiGrid, { "diff_cnt" : event.item.check_stock - event.item.current_stock }   , event.rowIndex );
                     // 금액 갱신 ( 판매금액)
                        AUIGrid.updateRow(auiGrid, { "sale_amt" : event.item.sale_price *  event.item.check_stock   }   , event.rowIndex );
                      // 금액 갱신 ( 차이금액(판매가) )
                        AUIGrid.updateRow(auiGrid, { "diff_amt" : event.item.sale_price * ( event.item.check_stock - event.item.current_stock ) }   , event.rowIndex );

                  }
                  fnCalcTotal();
                  
               }   
      
               break;
            } 
         }
         
      // part_no 으로 검색해온 정보 아이템(row) 반환 (엔터 or 마우스 클릭시 호출).
      function fnGetPartItem(part_no) {
         var item;
         $.each(recentPartList, function(index, row) {
            if(row.part_no == part_no) {
               item = row;
               return false; // 중지
            }
         });
          return item;
       };   
      
       
      // 총판매가,매입가, 요청품목수 ㄱㅖ산}
      function fnCalcTotal() {
         var saleTotalAmt = 0;
         var buyTotalAmt = 0;
         var overTotalAmt = 0;
         var underTotalAmt = 0;
         var adjustQty = 0;
         
         // 화면에 보여지는 그리드 데이터 목록
         var gridAllList = AUIGrid.getGridData(auiGrid);      
         if(gridAllList.length > 0 ){

            for (var i = 0; i < gridAllList.length; i++) {
               
               if( gridAllList[i].diff_cnt != 0  ) {         
                  
                  saleTotalAmt += Math.abs(gridAllList[i].diff_cnt) * gridAllList[i].sale_price;
                  buyTotalAmt +=  Math.abs(gridAllList[i].diff_cnt) * gridAllList[i].buy_price;
                  
                  if(gridAllList[i].diff_cnt > 0){
                     overTotalAmt += Math.abs(gridAllList[i].diff_cnt) * gridAllList[i].buy_price;
                  }   
                  else {
                     underTotalAmt +=  Math.abs(gridAllList[i].diff_cnt) * gridAllList[i].buy_price;
                  }
                  adjustQty +=1;
               }                     
            }

            $M.setValue("sale_total_amt",saleTotalAmt);
            $M.setValue("buy_total_amt",buyTotalAmt);
            $("#lbl_buy_total_amt").text($M.setComma(buyTotalAmt));
            $("#lbl_over_total_amt").text($M.setComma(overTotalAmt));
            $("#lbl_under_total_amt").text($M.setComma(underTotalAmt));
            $M.setValue("adjust_qty",adjustQty);            
         }
       }   
       
      function goRefCheckStock() {
         
         var param = {
               s_warehouse_cd : "${SecureUser.org_code}"
         };
         
         var poppupOption = "";
         $M.goNextPage("/part/part0505p02", $M.toGetParam(param), {popupStatus : poppupOption});
         
      }
      
      // 실사참조 팝업에서 받아온 값
      function setCheckStockInfo(rowArr) {
         var params = AUIGrid.getGridData(auiGrid);
         // 실사참조 팝업에서 받아온 값 중복체크
         for (var i = 0; i < rowArr.length; i++ ) {
            var rowItems = AUIGrid.getItemsByValue(auiGrid, "part_no", rowArr[i].part_no);
             if (rowItems.length != 0){
                alert("부품번호를 다시 확인하세요.\n"+rowArr[i].part_no+" 이미 입력한 부품번호입니다.");
                return false;                
             }
         }
         
         var partNo ='';
         var partName ='';
         var partUnit ='';
         var outputCount ='';
         var storageName ='';
         var row = new Object();
         if(rowArr != null) {
            for(i=0; i<rowArr.length; i++) {
               partNo = typeof rowArr[i].part_no == "undefined" ? partNo : rowArr[i].part_no;
               partName = typeof rowArr[i].part_name == "undefined" ? partName : rowArr[i].part_name;
               storageName = typeof rowArr[i].storage_name == "undefined" ? storageName : rowArr[i].storage_name;
               row.part_no = partNo;
               row.part_name = partName;
               row.storage_name =   rowArr[i].storage_name; 
               row.sale_price =  rowArr[i].sale_price;
               row.sale_amt =  rowArr[i].sale_price *  rowArr[i].current_stock;
               row.current_stock =  rowArr[i].current_stock;
               row.check_stock =  rowArr[i].check_stock;
               row.diff_cnt =  rowArr[i].diff_cnt;
               row.remark = rowArr[i].remark;
               row.diff_amt =  rowArr[i].diff_amt;
               row.buy_price =  "0";   //등록시에는 평균매입가 세팅안함
               row.buy_amt =  "0";      //등록시에는 평균매입합계 세팅안함
               row.part_check_stock_seq =  rowArr[i].part_check_stock_seq;
               row.part_adjust_cd =   10;
               AUIGrid.addRow(auiGrid, row, 'last');
            }
         }
      }


      // 저장
      function goSave(isRequestAppr) {
         
         var frm = document.main_form;   
         
           // validation check
           if($M.validation(frm) == false) {
              return;
           }

          // 벨리데이션
         if (fnCheckGridEmpty() === false){
            alert("필수 항목은 반드시 값을 입력해야합니다.");
            return false;
         } 
           
         // 화면에 보여지는 그리드 데이터 목록
         var gridAllList = AUIGrid.getGridData(auiGrid);      
         if(gridAllList.length < 1 ){
            alert("저장할 정보가 없습니다.");
            return;
         }
         
         for (var i = 0; i < gridAllList.length; i++) {
            
            if( gridAllList[i].diff_cnt == 0){
               AUIGrid.showToastMessage(auiGrid, i, 5, "차이수량이 없습니다");
               return;   
            }
            
            if( gridAllList[i].diff_cnt != 0 && gridAllList[i].remark == '' ) {         
               AUIGrid.showToastMessage(auiGrid, i, 6, "차이수량이 있는경우 사유 값은 필수값입니다.");
               return;      
            }   
            
            partCnt= gridAllList.length;
            partName = gridAllList[0].part_name;
            
         }
            

          if (isRequestAppr != undefined){
            $M.setValue("save_mode", "appr"); // 결재요청
            if(confirm("결재 후 수정 및 삭제가 제한됩니다.\n계속 진행하시겠습니까?") == false){
               return false;
            }
         } else {
            $M.setValue("save_mode", "save"); //저장
            if(confirm("저장하시겠습니까?") == false){
               return false;
            }
         } 
           
         
          //재고조정요청 상세내역 배열로 만들어서 넘기기 ( 그리드 )    
         var partNoArr = [];
         var partCheckStockSeqArr = [];
         var partAdjustCdArr = [];
         var currentStockArr = [];
         var checkStockArr = [];
         var warehouseCdArr = [];
         var stockDtArr = [];
         
         var salePriceArr = [];
         var buyPriceArr = [];
         var diffCntArr = [];
         
         var saleAmtArr = [];
         var diffAmtArr = [];
         var buyAmtArr = [];
         
         var remarkArr = [];   
         var cmdArr = [];
      
         // 화면에 보여지는 그리드 데이터 목록
         var gridAllList = AUIGrid.getGridData(auiGrid);
         
         for (var i = 0; i < gridAllList.length; i++) {
            
            partNoArr.push(gridAllList[i].part_no);
            warehouseCdArr.push("${SecureUser.org_code}");
            stockDtArr.push("${inputParam.s_current_dt}");
            partCheckStockSeqArr.push(gridAllList[i].part_check_stock_seq);
            partAdjustCdArr.push(gridAllList[i].part_adjust_cd);
            
            currentStockArr.push(gridAllList[i].current_stock);
            checkStockArr.push(gridAllList[i].check_stock);
         
            salePriceArr.push(gridAllList[i].sale_price);
            buyPriceArr.push(gridAllList[i].buy_price);
            diffCntArr.push(gridAllList[i].diff_cnt);
            
            saleAmtArr.push(gridAllList[i].sale_amt);
            diffAmtArr.push(gridAllList[i].diff_amt);      
            buyAmtArr.push(gridAllList[i].buy_amt);
            
            remarkArr.push(gridAllList[i].remark);      
            cmdArr.push("C");
            
         }

         
         
         var option = {
               isEmpty : true
         };
         
         var param = {
                           
               //재고조정요청 마스터 세팅      

               warehouse_cd    : "${SecureUser.org_code}" ,
               remark_master    : $M.getValue("remark_master"),
               count_remark    : partName + " 외 " + partCnt + "건",

               sale_total_amt : $M.getValue("sale_total_amt"),
               buy_total_amt : $M.getValue("buy_total_amt"),
               adjust_qty : $M.getValue("adjust_qty"),
               
               // 결재요청일자 추가 (req_dt)
               req_dt : $M.getValue("req_dt"),

               part_no_str : $M.getArrStr(partNoArr, option),
               warehouse_cd_str : $M.getArrStr(warehouseCdArr, option),
               stock_dt_str : $M.getArrStr(stockDtArr, option),
               part_check_stock_seq_str : $M.getArrStr(partCheckStockSeqArr, option),
               part_adjust_cd_str : $M.getArrStr(partAdjustCdArr, option),
               
               
               current_stock_str : $M.getArrStr(currentStockArr, option),
               check_stock_str : $M.getArrStr(checkStockArr, option), 
               
               
               sale_price_str : $M.getArrStr(salePriceArr, option),
               buy_price_str : $M.getArrStr(buyPriceArr, option), 
               diff_cnt_str : $M.getArrStr(diffCntArr, option), 
               
               sale_amt_str : $M.getArrStr(saleAmtArr, option), 
               diff_amt_str : $M.getArrStr(diffAmtArr, option), 
               buy_amt_str : $M.getArrStr(buyAmtArr, option),
               
               remark_str : $M.getArrStr(remarkArr, option), 
               cmd_str : $M.getArrStr(cmdArr, option),
               
               //결제선 가져오기
               appr_job_seq : $M.getValue("appr_job_seq"),
               appr_job_cd : $M.getValue("appr_job_cd"),
               appr_status_cd : $M.getValue("appr_status_cd"),
               appr_mem_no_str : $M.getValue("appr_mem_no_str"),
               save_mode : $M.getValue("save_mode")
            }
         
          
          
          
         $M.goNextPageAjax(this_page+"/save", $M.toGetParam(param), {method : 'POST'},
            function(result) {
                if(result.success) {
                   alert("저장이 완료되었습니다.");
                   fnList();
               }
            }
         );
      }
            
      
      //결재요청시
      function goRequestApproval() {
         goSave('requestAppr');
      }
      
      //행추가
      function fnAdd() {         

          var item = new Object();
          item.part_no = "";  
          item.part_name = "";     
          item.part_storage_seq = "";      
          item.current_stock = ""; 
          item.check_stock = "";
          item.diff_cnt = "";
          item.remark = "";
          item.sale_price = "0";
          item.buy_price = "0";
          item.buy_amt = "0";
          item.sale_amt = "0";
          item.part_check_stock_seq = "";
          item.part_adjust_cd="10"
         AUIGrid.addRow(auiGrid, item, 'last');                           
         
      }
      
      
      function goPartList() {         
         var items = AUIGrid.getAddedRowItems(auiGrid);
         for (var i = 0; i < items.length; i++) {
            if (items[i].part_no == "") {
               alert("추가된 행을 입력하고 시도해주세요.");
               return;
            }
         }

         if(fnCheckGridEmpty(auiGrid)) {
            
            var param = {
                    's_warehouse_cd' : $M.getValue('warehouse_cd'),
                    's_only_warehouse_yn' : "N",   // 센터일 때만 Y로 넘김 -> 전체 다 나오게 변경
//                     's_cust_no' : $M.getValue('cust_no')
             };
            
            openSearchPartPanel('setPartInfo', 'Y', $M.toGetParam(param));
         }

      }
      
      
      // 부품조회 창에서 받아온 값
      function setPartInfo(rowArr) {
         var params = AUIGrid.getGridData(auiGrid);
         // 부품조회 창에서 받아온 값 중복체크
         for (var i = 0; i < rowArr.length; i++ ) {
            var rowItems = AUIGrid.getItemsByValue(auiGrid, "part_no", rowArr[i].part_no);
             if (rowItems.length != 0){
//                 alert("부품번호를 다시 확인하세요.\n"+rowArr[i].part_no+" 이미 입력한 부품번호입니다.");
                return "부품번호를 다시 확인하세요.\n"+rowArr[i].part_no+" 이미 입력한 부품번호입니다.";                
             }
         }
         
         var partNo ='';
         var partName ='';
         var sale_price ='';
         var current_stock ='';
         var sale_amt ='';
         
         var row = new Object();
         if(rowArr != null) {
            for(i=0; i<rowArr.length; i++) {
               partNo = typeof rowArr[i].part_no == "undefined" ? partNo : rowArr[i].part_no;
               partName = typeof rowArr[i].part_name == "undefined" ? partName : rowArr[i].part_name;
               sale_price = typeof rowArr[i].cust_price == "undefined" ? sale_price : rowArr[i].cust_price;
               current_stock = typeof rowArr[i].part_warehouse_current == "undefined" ? current_stock : rowArr[i].part_warehouse_current;
               sale_amt = "0";
               
               row.part_no = partNo;
               row.part_name = partName;
               row.sale_price = sale_price;            
               row.current_stock = current_stock;
               row.check_stock = "0";
               row.sale_amt = sale_amt;
               row.buy_price = "0";
               row.buy_amt = "0";
               row.storage_name = rowArr[i].storage_name;    
               row.diff_cnt = 0 - current_stock;
               row.diff_amt = sale_price * ( 0 - current_stock );
               row.remark = "";
               row.part_check_stock_seq = "";
               row.part_adjust_cd = "10";
               AUIGrid.addRow(auiGrid, row, 'last');
            }
            fnCalcTotal();
         }
      }
      
      // 그리드 빈값 체크
      function fnCheckGridEmpty() {
         return AUIGrid.validation(auiGrid);
      }
      
      
      function fnList() {
         history.back(); 
      }   
      
      

      function fnDownloadExcel() {
         fnExportExcel(auiGrid, "부품재고조정요청");
      }
      
   </script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" name="warehouse_cd" id="warehouse_cd" value="${SecureUser.warehouse_cd != '' ? SecureUser.warehouse_cd : SecureUser.org_code}"><!-- 로그인한 사용자의 조직코드 -->
<div class="layout-box">
<!-- contents 전체 영역 -->
      <div class="content-wrap">
         <div class="content-box">
            <!-- 타이틀, 결재영역 -->   
            <div class="main-title detail">
               <div class="detail-left approval-left" style="align-items: center;">
                  <div class="left">
                     <button type="button" class="btn btn-outline-light" onclick="javascript:fnList()"><i class="material-iconskeyboard_backspace text-default"></i></button>
                     <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"></jsp:include>
                     <div style="min-width:80px; margin-top: auto; margin-bottom: auto; margin-right: 10px;">
	                     <span class="condition-item">상태 : ${apprBean.appr_proc_status_name}</span>
	                  </div>
                  </div>
               </div>
               <!-- 결재영역 -->
               <div class="p10"> 
                  <jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
               </div>
               <!-- /결재영역 -->
   
            </div>
<!-- /타이틀, 결재영역 -->
            <div class="contents">
<!-- 폼테이블 -->   
<!-- 상단 폼테이블 -->   

               <input type="hidden" id="buy_total_amt"    name="buy_total_amt"       value="0">
               <input type="hidden" id="sale_total_amt"    name="sale_total_amt"       value="0" >
               <div>
                  <table class="table-border">
                     <colgroup>
                        <col width="100px">
                        <col width="">
                        <col width="100px">
                        <col width="">
                        <col width="100px">
                        <col width="">
                        <col width="100px">
                        <col width="">
                     </colgroup>
                     <tbody>
                        <tr>
                           <th class="text-right">요청번호</th>
                           <td>
                              <div class="form-row inline-pd">
                                 <div class="col-5">
                                    <input type="text" class="form-control" "${ cycle.warehouse_name }" readonly="readonly" >
                                 </div>

                                 <div class="col-3">
                                    <button type="button" class="btn btn-primary-gra" onclick="javascript:goRefCheckStock();">실사참조</button>
                                 </div>
                              </div>
                           </td>
                           <th class="text-right">요청창고</th>
                           <td>
                              <input type="text" class="form-control width120px" id="warehouse_name" name="warehouse_name" value="${SecureUser.org_name}" readonly="readonly" >
                           </td>
                           <th class="text-right">요청품목수</th>
                           <td>
                              <input type="text" class="form-control width120px text-right" id="adjust_qty" name="adjust_qty"  readonly="readonly" >
                           </td>
                           <th class="text-right">작성일</th>
                           <td>
                              <div class="input-group">
                                 <input    type="text" class="form-control border-right-0  calDate" id="reg_dt" 
                                       name="reg_dt" dateformat="yyyy-MM-dd" alt="작성일" 
                                       value="${inputParam.s_current_dt}">
                              </div>
                           </td>
                        </tr>
                        <tr>
                           <th class="text-right">결재요청일</th>
                           <td>
                              <div class="input-group">
                                 <input    type="text" class="form-control border-right-0  calDate" id="req_dt" 
                                       name="req_dt" dateformat="yyyy-MM-dd" alt="결재요청일" disabled="disabled"
                                       value="${inputParam.s_current_dt}">
                              </div>
                           </td>
                           <th class="text-right">반영완료일</th>
                           <td>
                              <div class="input-group">
                                 <input type="text" class="form-control border-right-0  calDate" id="adjust_dt" 
                                       name="adjust_dt" dateformat="yyyy-MM-dd" alt="반영완료일" disabled="disabled"
                                       value="">
                              </div>
                           </td>
                           <th rowspan="2" class="text-right">결재자의견</th>
                           <td rowspan="2" colspan="3" class="v-align-top">
                              <div style="min-height: 82px;">
                                 <!--  -->
                                 <table class="table-border doc-table md-table">
                                    <colgroup>
                                       <col width="40px">
                                       <col width="140px">
                                       <col width="55px">
                                       <col width="">
                                    </colgroup>
                                    <thead>
                                       <!-- 퍼블리싱 파일의 important 속성 때문에 dev에 선언한 클래스가 안되서 인라인 CSS로함 -->
                                       <tr><th class="th" style="font-size: 12px !important">구분</th>
                                       <th class="th" style="font-size: 12px !important">결재일시</th>
                                       <th class="th" style="font-size: 12px !important">담당자</th>
                                       <th class="th" style="font-size: 12px !important">특이사항</th>
                                    </tr></thead>
                                    <tbody>
                                       <c:forEach var="list" items="${apprMemoList}">
                                          <tr>
                                             <td class="td" style="text-align: center; font-size: 12px !important">${list.appr_status_name }</td>
                                             <td class="td" style="font-size: 12px !important">${list.proc_date }</td>
                                             <td class="td" style="text-align: center; font-size: 12px !important">${list.appr_mem_name }</td>
                                             <td class="td" style="font-size: 12px !important">${list.memo }</td>
                                          </tr>
                                       </c:forEach>
                                    </tbody>
                                 </table>
                              </div>                     
                           </td>
                        </tr>
                        <tr>
                           <th class="text-right">비고</th>
                           <td colspan="3">
                              <textarea class="form-control" style="height: 100%;" id="remark_master" name="remark_master" ></textarea>
                           </td>
                        </tr>                        
                     </tbody>
                  </table>
               </div>
<!-- /상단 폼테이블 -->
<!-- 하단 폼테이블 -->            
                  <div>
<!-- 부품내역 -->
                     <div class="title-wrap mt10">
                        <h4>부품내역</h4>
                        <div>
                           <span class="text-warning">※  평균매입가는 매입자료에 따라 매일 업데이트 되며, 재고조정요청시 재고반영일 기준으로 최종저장되어 관리됩니다.</span>
                           <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>            
                        </div>
                     </div>
                     
                     <div id="auiGrid" style="margin-top: 5px; height: 350px;">
                     </div>
<!-- /부품내역 -->
                  </div>
<!-- /하단 폼테이블 -->   
<!-- 합계그룹 -->
                  <div class="row inline-pd mt10" id="avg_price_sum" name="avg_price_sum" >
                     <div class="col-3">
                        <table class="table-border">
                           <colgroup>
                              <col width="100%">
                           </colgroup>
                           <tbody>
                              <tr>
                                 <th class="text-right"><label >금액(매입가)</label></th>
                              </tr>
                           </tbody>
                        </table>
                     </div>
                     <div class="col-3">
                        <table class="table-border">
                           <colgroup>
                              <col width="40%">
                              <col width="60%">
                           </colgroup>
                           <tbody>
                              <tr>
                                 <th class="text-right th-sum">과다금액</th>
                                 <td class="text-right td-gray"><label id="lbl_over_total_amt" name="lbl_over_total_amt" format="decimal" ></label></td>
                              </tr>
                           </tbody>
                        </table>
                     </div>
                     <div class="col-3">
                        <table class="table-border">
                           <colgroup>
                              <col width="40%">
                              <col width="60%">
                           </colgroup>
                           <tbody>
                              <tr>
                                 <th class="text-right th-sum">부족금액</th>
                                 <td class="text-right td-gray"   ><label id="lbl_under_total_amt" name="lbl_under_total_amt" format="decimal" ></label></td>
                              </tr>
                           </tbody>
                        </table>
                     </div>
                     <div class="col-3">
                        <table class="table-border">
                           <colgroup>
                              <col width="40%">
                              <col width="60%">
                           </colgroup>
                           <tbody>
                              <tr>
                                 <th class="text-right th-sum">차이금액합계</th>
                                 <td class="text-right td-gray"><label id="lbl_buy_total_amt" name="lbl_buy_total_amt" format="decimal"  ></label></td>
                              </tr>
                           </tbody>
                        </table>
                     </div>                  
                  </div>
<!-- /합계그룹 -->
<!-- /폼테이블 -->
<!-- 그리드 서머리, 컨트롤 영역 -->
               <div class="btn-group mt5">                  
                  <div class="right">
                     <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
                  </div>
               </div>
<!-- /그리드 서머리, 컨트롤 영역 -->
            </div>
            
         </div>   
         <jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>      
      </div>
   </div>   

   <input type="hidden" id="save_mode" name="save_mode"> <!-- appr(결재요청 후 저장), save(저장) -->   

</form>
</body>
</html>