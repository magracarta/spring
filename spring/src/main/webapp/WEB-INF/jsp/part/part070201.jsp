<%@ page contentType="text/html;charset=utf-8" language="java" %><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 코드관리 > 부품정보일괄적용 > null > null
-- 작성자 : 박준영
-- 최초 작성일 : 2020-11-27 11:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">

        var auiGrid;
        var auiGridExcel;
        var auiGridSample;
        var warehouseList;

        $(document).ready(function () {
            fnInit();
            createInitGrid();
            createInitSplitGrid();
            createAUIGridExcel();
            createAUIGridSample();

            fileUploadInit();
        });

        function fnInit() {
            warehouseList = ${warehouseList};
            $M.setValue("code_name", $M.getValue("code_value"));
        }

        function fileUploadInit() {
            // IE10, 11은 readAsBinaryString 지원을 안함. 따라서 체크함.
            var rABS = typeof FileReader !== "undefined"
                && typeof FileReader.prototype !== "undefined"
                && typeof FileReader.prototype.readAsBinaryString !== "undefined";

            // HTML5 브라우저인지 체크 즉, FileReader 를 사용할 수 있는지 여부
            function checkHTML5Brower() {
                var isCompatible = false;
                if (window.File && window.FileReader && window.FileList
                    && window.Blob) {
                    isCompatible = true;
                }
                return isCompatible;
            }

            // 파일 선택하기
            $('#fileSelector').on('change', function (evt) {
                if (!checkHTML5Brower()) {
                    alert("브라우저가 HTML5 를 지원하지 않습니다.\r\n서버로 업로드해서 해결하십시오.");
                    return;
                } else {
                    var data = null;
                    var file = evt.target.files[0];
                    if (typeof file == "undefined") {
                        alert("파일 선택 시 오류 발생!!");
                        return;
                    }
                    var reader = new FileReader();

                    reader.onload = function (e) {
                        var data = e.target.result;

                        /* 엑셀 바이너리 읽기 */
                        var workbook;

                        if (rABS) { // 일반적인 바이너리 지원하는 경우
                            workbook = XLSX.read(data, {
                                type: 'binary'
                            });
                        } else { // IE 10, 11인 경우
                            var arr = fixdata(data);
                            workbook = XLSX.read(btoa(arr), {
                                type: 'base64'
                            });
                        }

                        var jsonObj = process_wb(workbook);

                        if(jsonObj == false) {
                        	return false;
                        }

                        var partNoArr = [];
                        var applyDataArr = [];

                        for(var i = 0; i < jsonObj[Object.keys(jsonObj)[0]].length; i++) {
                        	partNoArr.push(jsonObj[Object.keys(jsonObj)[0]][i].origin_part_no);
                        	applyDataArr.push(jsonObj[Object.keys(jsonObj)[0]][i].apply_data);
                        }

            			var frm = document.main_form;
            			frm = $M.toValueForm(document.main_form);

                        var option = {
            					isEmpty : true
            			};

            			$M.setValue(frm, "part_no_str", $M.getArrStr(partNoArr, option));
            			$M.setValue(frm, "apply_data_str", $M.getArrStr(applyDataArr, option));
            			$M.setValue("apply_name", $M.getValue("code_value"));

                        $M.goNextPageAjax(this_page + "/searchPartInfo", frm, {method: 'POST', timeout: 60 * 60 * 1000},
                            function (result) {
                                if (result.success) {
                                    createAUIGrid(result.list);
                                    alert("서버에서 확인된 " + result.list.length+ "건이 적용 예정입니다.");
                                }
                        });
//                         createAUIGrid(jsonObj[Object.keys(jsonObj)[0]]);
                    };

                    if (rABS) {
                        reader.readAsBinaryString(file);
                    } else {
                        reader.readAsArrayBuffer(file);
                    }
                }
            });
        }

        // IE10, 11는 바이너리스트링 못읽기 때문에 ArrayBuffer 처리 하기 위함.
        function fixdata(data) {
            var o = "", l = 0, w = 10240;
            for (; l < data.byteLength / w; ++l) {
                o += String.fromCharCode.apply(null, new Uint8Array(data.slice(l * w, l * w + w)));
            }
            o += String.fromCharCode.apply(null, new Uint8Array(data.slice(l * w)));
            return o;
        }

        // 파싱된 시트의 CDATA 제거 후 반환.
        function process_wb(wb) {
            var output = "";
            output = JSON.stringify(to_json(wb));
            output = output.replace(/<!\[CDATA\[(.*?)\]\]>/g, '$1');
            return JSON.parse(output);
        }

        // 엑셀 시트를 파싱하여 반환
        function to_json(workbook) {

        	var result = {};

            var checkEng = /[a-zA-Z]/;
            var checkData = workbook.Sheets[workbook.SheetNames[0]]['!ref'];
            var cnt = 0;
            var checkCnt = 0;

            for(var i = 1; i <= checkData.length; i++) {
            	if(checkEng.test(checkData.substring(cnt, i))) {
            		checkCnt++;
            	};
            	cnt++;
            }

        	var subLength = checkCnt == 2 ? 4 : 5;
            var length = workbook.Sheets[workbook.SheetNames[0]]['!ref'].substring(subLength);
            var apply = $M.getValue("apply_cell");

            var roa = [];
            var i = 1;
            var totalCnt = 0;
            while(i <= length){
               var temp = {};
               i++;
               if(!workbook.Sheets[workbook.SheetNames[0]].hasOwnProperty("A"+i) || !workbook.Sheets[workbook.SheetNames[0]].hasOwnProperty(apply+i)) {
           		  continue;
               }
               // 0도 false로 취급하여 0이 아닌 조건추가함. 21-11-18 김상덕
               if(workbook.Sheets[workbook.SheetNames[0]]["A"+i]['v'] == "" || (workbook.Sheets[workbook.SheetNames[0]][apply+i]['v'] != 0 && workbook.Sheets[workbook.SheetNames[0]][apply+i]['v'] == "")) {
            	  continue;
               }
               temp["origin_part_no"] = workbook.Sheets[workbook.SheetNames[0]]["A"+i]['v'];
               temp["apply_data"] = workbook.Sheets[workbook.SheetNames[0]][apply+i]['v'];
               roa.push(temp);
               totalCnt++;
            }

            if(roa.length == 0) {
            	alert("적용할 데이터가 없습니다. 확인 후 다시 시도해주세요.");
            	return false;
            }

            if(length-1 != totalCnt) {
            	alert((length-1) + "건중 데이터 이상 건을 제외한 " + totalCnt + "건을 엑셀에서 불러왔습니다.");
            };
//             for(var i = 2; i <= length; i++){
//                var temp = {};
//                if(workbook.Sheets[workbook.SheetNames[0]].hasOwnProperty(apply+i)) {
// 	               temp["origin_part_no"] = workbook.Sheets[workbook.SheetNames[0]]["A"+i]['v'];
// 	               temp["apply_data"] = workbook.Sheets[workbook.SheetNames[0]][apply+i]['v'];
// 	               roa.push(temp);
//                } else {
//             	   alert("적용할 셀에 데이터가 없습니다. 확인 후 다시 시도해주세요.");
//             	   return false;
//                }
//             }

            result[workbook.SheetNames[0]] = roa;
            return result;

//             var result = {};
//             workbook.SheetNames.forEach(function (sheetName) {
//                 // JSON 으로 파싱
//                 var roa = XLSX.utils.sheet_to_row_object_array(workbook.Sheets[sheetName]);

//                 if (roa.length > 0) {
//                     result[sheetName] = roa;
//                 }
//             });
//             return result;
        }

        function fnChangeGridData() {
            if("S.SAFE_STOCK" == $M.getValue("code_value")){
                $("#apply_center").attr("disabled", false);
            } else{
                $M.setValue("apply_center", "");
                $("#apply_center").attr("disabled", true);
            }
            $M.setValue("code_name", $M.getValue("code_value"));
            var dataField = $M.getValue("code_value");
            var headerText = $("#code_value option:selected").text();

            // 8 헤더 속성값 변경하기
            AUIGrid.setColumnProp(auiGrid, 8, {
                headerText: headerText,
                style: "my-strong-column",
                headerStyle: "my-strong-header"
            });
        }

        function goSave() {
        	if(!confirm("저장하시겠습니까?")) {
        		return false;
        	}
            if($M.getValue("code_value").substring(0,1) != "V" && $M.getValue("code_value").substring(0,2) != "MV"){
                var col1 = AUIGrid.getColumnIndexByDataField(auiGridSplit,"calc_list_price");
                var col2 = AUIGrid.getColumnIndexByDataField(auiGridSplit,"calc_net_price");
                var col3 = AUIGrid.getColumnIndexByDataField(auiGridSplit,"calc_special_price");
                var col4 = AUIGrid.getColumnIndexByDataField(auiGridSplit,"calc_strategy_price");
                var col5 = AUIGrid.getColumnIndexByDataField(auiGridSplit,"calc_in_stock_price");
                var col6 = AUIGrid.getColumnIndexByDataField(auiGridSplit,"calc_vip_price");
                var col7 = AUIGrid.getColumnIndexByDataField(auiGridSplit,"calc_vip_sale_price");
                var col8 = AUIGrid.getColumnIndexByDataField(auiGridSplit,"calc_cust_price");
                var col9 = AUIGrid.getColumnIndexByDataField(auiGridSplit,"calc_sale_price");
                var col10 = AUIGrid.getColumnIndexByDataField(auiGridSplit,"calc_mng_agency_price");
                var col11 = AUIGrid.getColumnIndexByDataField(auiGridSplit,"calc_part_margin_cd");
                var colList = [];
                colList.push(col1);
                colList.push(col2);
                colList.push(col3);
                colList.push(col4);
                colList.push(col5);
                colList.push(col6);
                colList.push(col7);
                colList.push(col8);
                colList.push(col9);
                colList.push(col10);
                colList.push(col11);
                AUIGrid.removeColumn(auiGridSplit, colList);
                AUIGrid.removeColumn(auiGrid, colList);
            }

        	// 데이터 많을경우 로딩바 작동하지 않아 강제 노출 후 타임아웃추가함.
       		top.$('#popup-bg-loading').show();
   			top.$('#bowlG').show();

        	setTimeout(function (){
        		var frm = $M.toValueForm(document.main_form);

                var concatCols = [];
                var concatList = [];

    			var unit = 500;
                var gridLength = AUIGrid.getGridData(auiGrid).length;
                // (Q&A 13275) 데이터 많을경우 서버로 전송할 파라미터가 누락되어 나누어 전송되도록 수정. 21.11.17 김상덕
                if (gridLength > unit) {

                	var gridData = AUIGrid.getGridData(auiGrid);
                	var packCnt = parseInt(gridLength / unit) + (gridLength % unit > 0 ? 1 : 0);

                	for (var i = 0; i < packCnt; i++) {
                		var fromIdx = i * unit;
                		var toIdx = (i+1) * unit;

                		toIdx = toIdx > gridLength ? gridLength : toIdx;

                		var sendData = gridData.slice(fromIdx, toIdx);
                		AUIGrid.clearGridData(auiGridSplit);
                		AUIGrid.setGridData(auiGridSplit, sendData);

    					var gridFrm = fnGridObjDataToForm(auiGridSplit);
                    	$M.copyForm(gridFrm, frm);
                    	$M.goNextPageAjax(this_page + "/save", gridFrm, {method : 'POST', async : false, timeout : 1000 * 60 * 10},
                            function (result) {
                                if(result.success) {
                                    if (i == packCnt -1) {
                                    	alert("저장이 완료되었습니다.");
    	                                window.location.reload();
                                    }
                                }
                            }
                        );
                	}
                } else {
                	var gridIds = [auiGrid];
                    for (var i = 0; i < gridIds.length; ++i) {
                        concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
                        concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
                    }
                	var gridFrm = fnGridDataToForm(concatCols, concatList);
                	$M.copyForm(gridFrm, frm);
                	$M.goNextPageAjax(this_page + "/save", gridFrm, {method : 'POST'},
                        function (result) {
                            if(result.success) {
                                alert("저장이 완료되었습니다.");
                                window.location.reload();
                            }
                        }
                    );
                }
        	}, 1000);
        }

        function fnExcelDownload() {
            var exportProps = {
                footers : [
                {
                    text : "※주의사항※ 매입처 일괄변경 시 매입처 컬럼의 셀 서식을 텍스트로 변경 후 진행바랍니다." , style : { fontSize:15, color:"#FF3232"}
                },
               ]

            };
            fnExportExcel(auiGridSample, "업로드 샘플", exportProps);
        }

        function fnDownload() {
            var param = {};
            $M.goNextPageAjax(this_page + "/download", $M.toGetParam(param), {method: 'get'},
                function (result) {
                    if (result.success) {
                        AUIGrid.setGridData(auiGridExcel, result.list);
//                         $("#total_cnt").html(result.total_cnt);
                        var exportProps = {};
                        fnExportExcel(auiGridExcel, "부품정보다운로드", exportProps);
                    }
            });
        }

        function goRemove() {
            // 그리드 초기화
            AUIGrid.clearGridData(auiGrid);
            // 설정초기화
            $M.clearValue({field: ["file_name", "fileSelector"]});
            $("#total_cnt").html(0);
        }

        function goSearchFile() {
            if($M.getValue("code_value") == "S.SAFE_STOCK" && $M.getValue("apply_center") == ""){
                alert("적용할 센터를 선택해주세요.");
                return false;
            }
            $M.setValue("s_warehouse_cd",$M.getValue("apply_center")); // 저장 시 엑셀업로드된 적용센터 기준으로 저장하기위하여 추가
            // openFileUploadPanel('setFileInfo', 'upload_type=PART&file_type=etc');
            goRemove();
            $("#fileSelector").click();
        }

        function getCmaFileName(obj) {
            var fileObj, pathHeader, pathMiddle, pathEnd, allFilename, fileName, extName;
            if (obj == "[object HTMLInputElement]") {
                fileObj = obj.value
            } else {
                fileObj = document.getElementById(obj).value;
            }

            if (fileObj != "") {
                pathHeader = fileObj.lastIndexOf("\\");
                pathMiddle = fileObj.lastIndexOf(".");
                pathEnd = fileObj.length;
                fileName = fileObj.substring(pathHeader + 1, pathMiddle);
                extName = fileObj.substring(pathMiddle + 1, pathEnd);
                allFilename = fileName + "." + extName;
            } else {
                alert("파일을 선택해주세요");
                return false;
            }

            $M.setValue("file_name", allFilename);
        }

        function createInitGrid() {
            var gridPros = {
                // Row번호 표시 여부
                showRowNumColumn: true
            };

            var columnLayout = [
                {
                    headerText: "상품코드",
                    dataField: "M.PART_NO",
                    width: "140",
                    minWidth: "130"
                },
                {
                    headerText: "부품명",
                    dataField: "M.PART_NAME",
                    width: "240",
                    minWidth: "230",
                    style: "aui-left"
                },
                {
                    headerText: "전체현재고",
                    dataField: "origin_current_stock",
                    width: "100",
                    minWidth: "100"
                },
                {
                    headerText: "평균매입가",
                    dataField: "origin_in_avg_price",
                    dataType: "numeric",
                    formatString: "#,##0",
                    width: "100",
                    minWidth: "90",
                    style: "aui-right"
                },
                {
                    headerText: "적용항목",
                    children: [
                        {
                            headerText: "현재",
                            dataField: $M.getValue("code_value"),
                            width: "240",
                            minWidth: "230",
                        },
                        {
                            headerText: "부품명",
                            dataField: "c2",
                            width: "240",
                            minWidth: "230"
                        },
                        {
                            dataField: "warehouse_cd",
                            visible : false
                        }
                    ]
                }
            ];

            // 실제로 #grid_wrap에 그리드 생성
            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            // 그리드 갱신
            AUIGrid.setGridData(auiGrid, []);
        }

        // 너무 많은 데이터를 저장할 때, 해당 그리드로 나누어서 진행
        function createInitSplitGrid() {


            var gridProps = {
            };

            var columnLayout = [
                {
	                headerText: "상품코드",
	                dataField: "origin_part_no",
                },
                {
                    headerText: "부품명",
                    dataField: "origin_part_name",
                },
                {
                    headerText: "전체현재고",
                    dataField: "origin_current_stock",
                },
                {
                    headerText: "평균매입가",
                    dataField: "origin_in_avg_price",
                    dataType: "numeric",
                },
                {
                    headerText: "적용항목",
                    children: [
                        {
                            headerText: "현재",
                            dataField: "old_data",
                        },
                        {
                            headerText: $("#code_value option:selected").text(),
                            dataField: "apply_data",
                        }
                    ]
                },
                {
                    // headerText: "list_price",
                    dataField: "calc_list_price",
                    visible : false
                },
                {
                    // headerText: "net_price",
                    dataField: "calc_net_price",
                    visible : false
                },
                {
                    // headerText: "special_price",
                    dataField: "calc_special_price",
                    visible : false
                },
                {
                    // headerText: "전략가",
                    dataField: "calc_strategy_price",
                    visible : false
                },
                {
                    // headerText: "입고단가",
                    dataField: "calc_in_stock_price",
                    visible : false
                },
                {
                    // headerText: "VIP판매가",
                    dataField: "calc_vip_price",
                    visible : false
                },
                {
                    // headerText: "최종VIP판매가",
                    dataField: "calc_vip_sale_price",
                    visible : false
                },
                {
                    // headerText: "일반판매가",
                    dataField: "calc_cust_price",
                    visible : false
                },
                {
                    // headerText: "최종일반판매가",
                    dataField: "calc_sale_price",
                    visible : false
                },
                {
                    // headerText: "대리점가",
                    dataField: "calc_mng_agency_price",
                    visible : false
                },
                {
                    // headerText: "부품구분",
                    dataField: "calc_part_margin_cd",
                    visible : false
                },
            ];

            // 실제로 #grid_wrap에 그리드 생성
            auiGridSplit = AUIGrid.create("#auiGridSplit", columnLayout, gridProps);
            // 그리드 갱신
            AUIGrid.setGridData(auiGridSplit, []);

//             $("#auiGrid").resize();
        }

        // 샘플 다운로드용 그리드 생성
        function createAUIGridSample() {
            var gridPros = {
                showRowNumColumn : false
            }

            var columnLayout = [
                {
                    headerText : "상품코드",
                    dataField: "origin_part_no"
                },
                {
                    headerText : "부품명",
                    dataField: "part_name"
                },
                {
                    headerText : "부품번호",
                    dataField: "part_no"
                },
//                 {
//                     headerText : "부품 신번호",
//                     dataField: "part_new_no"
//                 },
//                 {
//                     headerText : "부품 구번호",
//                     dataField: "part_old_no"
//                 },
//                 {
//                     headerText : "신번호 호환성코드",
//                     dataField: "part_new_exchange_cd"
//                 },
//                 {
//                     headerText : "구번호 호환성코드",
//                     dataField: "part_old_exchange_cd"
//                 },
//                 {
//                     headerText : "수요예측번호",
//                     dataField: "dem_fore_no"
//                 },
//                 {
//                     headerText : "안전재고",
//                     dataField: "part_safe_stock"
//                 },
//                 {
//                     headerText : "안전재고2",
//                     dataField: "part_safe_stock2"
//                 },
//                 {
//                     headerText : "메이커",
//                     dataField: "maker_cd"
//                 },
                {
                    headerText : "생산구분코드",
                    dataField: "part_production_cd"
                },
                {
                    headerText : "관리구분코드",
                    dataField: "part_mng_cd"
                },
                {
                    headerText : "분류구분코드",
                    dataField: "part_group_cd"
                },
                {
                    headerText : "수요예측자료여부",
                    dataField: "dem_fore_yn"
                },
                {
                    headerText : "homi관리품여부",
                    dataField: "homi_yn"
                },
                {
                    headerText : "출하관리품여부",
                    dataField: "out_mng_yn"
                },
                {
                    headerText : "정비지시서제외여부",
                    dataField: "repair_yn"
                },
//                 {
//                     headerText : "포장단위",
//                     dataField: "part_pack_unit"
//                 },
//                 {
//                     headerText : "중량",
//                     dataField: "part_weight_kg"
//                 },
//                 {
//                     headerText : "발주단위",
//                     dataField: "order_unit"
//                 },
//                 {
//                     headerText : "구매리드타임",
//                     dataField: "part_pur_day_cnt"
//                 },
//                 {
//                     headerText : "최소 lot",
//                     dataField: "part_lot"
//                 },
//                 {
//                     headerText : "서비스%",
//                     dataField: "service_rate"
//                 },
                {
                    headerText : "매입처",
                    dataField: "deal_cust_no"
                },
//                 {
//                     headerText : "매입처2",
//                     dataField: "deal_cust_no2"
//                 },
//                 {
//                     headerText : "입고품질검사",
//                     dataField: "deal_ware_qual_ass"
//                 },
//                 {
//                     headerText : "금형관리NO",
//                     dataField: "deal_mold_cont_no_yn"
//                 },
//                 {
//                     headerText : "도면보유",
//                     dataField: "deal_floor_plan_yn"
//                 },
//                 {
//                     headerText : "매출정지일",
//                     dataField: "sale_stop_dt"
//                 },
//                 {
//                     headerText : "원산지",
//                     dataField: "part_country_cd"
//                 },
//                 {
//                     headerText : "호환모델",
//                     dataField: "part_model"
//                 },
                {
                    headerText : "LIST PRICE",
                    dataField: "list_price"
                },
                {
                    headerText : "NET PRICE",
                    dataField: "net_price"
                },
                {
                    headerText : "SPECIAL",
                    dataField: "special_price"
                },
                {
                    headerText : "입고단가",
                    dataField: "in_stock_price"
                },
                {
                    headerText : "전략가",
                    dataField: "strategy_price"
                },
                {
                    headerText : "VIP판매가",
                    dataField: "vip_price"
                },
                {
                    headerText : "일반판매가",
                    dataField: "cust_price"
                },
                {
                    // [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
                    // headerText : "대리점가",
                    headerText : "위탁판매점가",
                    dataField: "mng_agency_price"
                },
                {
                    headerText : "최종 VIP판매가",
                    dataField: "vip_sale_price"
                },
                {
                    headerText : "최종 일반판매가",
                    dataField: "sale_price"
                },
            ]

            var sampleData = [
                {
                    "origin_part_no" : "YK42",
                    "part_name" : "HOOK, 2TON",
                    "part_no" : "YK42",
                    "part_new_no" : "",
                    "part_old_no" : "",
                    "part_new_exchange_cd" : "",
                    "part_old_exchange_cd" : "",
                    "dem_fore_no" : "",
                    "part_safe_stock" : "0",
                    "part_safe_stock2" : "0",
                    "maker_cd" : "27",
                    "part_production_cd" : "1",
                    "part_mng_cd" : "9",
                    "part_group_cd" : "Y014",
                    "dem_fore_yn" : "N",
                    "homi_yn" : "N",
                    "out_mng_yn" : "N",
                    "repair_yn" : "Y",
                    "part_pack_unit" : "1",
                    "part_weight_kg" : "0",
                    "order_unit" : "1",
                    "part_pur_day_cnt" : "15",
                    "part_lot" : "1",
                    "service_rate" : "0",
                    "deal_cust_no" : "20110125101037278",
                    "deal_cust_no2" : "",
                    "deal_ware_qual_ass" : "",
                    "deal_mold_cont_no_yn" : "N",
                    "deal_floor_plan_yn" : "N",
                    "sale_stop_dt" : "20190404",
                    "part_country_cd" : "KR",
                    "part_model" : "",
                    "list_price" : "43000",
                    "net_price" : "43000",
                    "special_price" : "",
                    "in_stock_price" : "51600",
                    "strategy_price" : "",
                    "vip_price" : "80000",
                    "cust_price" : "104000",
                    "mng_agency_price" : "",
                    "vip_sale_price" : "80000",
                    "sale_price" : "104000",
                }
            ]

            // 실제로 #grid_wrap에 그리드 생성
            auiGridSample = AUIGrid.create("#auiGridSample", columnLayout, gridPros);
            // 그리드 갱신
            AUIGrid.setGridData(auiGridSample, sampleData);

            $("#auiGrid").resize();
        }

        // 부품정보다운로드용 그리드 생성
        function createAUIGridExcel() {
            var gridPros = {
                // Row번호 표시 여부
                showRowNumColumn: false
            };

            var columnLayout = [
            {
                headerText: "부품번호",
                dataField: "part_no",
                width: "120",
                minWidth: "120",
                style: "aui-center",
            }, {
                headerText: "부품명",
                dataField: "part_name",
                width: "180",
                minWidth: "180",
                style: "aui-center",
            }, {
                headerText: "현재고",
                dataField: "current_qty",
                width: "80",
                minWidth: "80",
                style: "aui-center",
            }, {
                headerText: "신번호",
                dataField: "part_new_no",
                width: "80",
                minWidth: "80",
                style: "aui-center",
            }, {
                headerText: "신번호 호환성",
                dataField: "part_new_no_exchange_name",
                width: "80",
                minWidth: "80",
                style: "aui-center",
            }, {
                headerText: "수요예측번호",
                dataField: "dem_fore_no",
                width: "80",
                minWidth: "80",
                style: "aui-center",
            }, {
                headerText: "안전재고",
                dataField: "part_safe_stock",
                width: "80",
                minWidth: "80",
                style: "aui-center",
            }, {
                headerText: "안전재고2",
                dataField: "part_safe_stock2",
                width: "80",
                minWidth: "80",
                style: "aui-center",
            }, {
                headerText: "메이커",
                dataField: "maker_name",
                width: "100",
                minWidth: "100",
                style: "aui-center",
            }, {
                headerText: "생산구분",
                dataField: "part_production_name",
                width: "80",
                minWidth: "80",
                style: "aui-center",
            }, {
                headerText: "관리구분",
                dataField: "part_mng_name",
                width: "80",
                minWidth: "80",
                style: "aui-center",
            }, {
                headerText: "산출구분",
                dataField: "part_output_price_name",
                width: "180",
                minWidth: "180",
                style: "aui-center",
            }, {
                headerText: "분류구분",
                dataField: "part_real_check_name",
                width: "80",
                minWidth: "80",
                style: "aui-center",
            }, {
                headerText: "부품그룹명",
                dataField: "part_group_name",
                width: "180",
                minWidth: "180",
                style: "aui-center",
            }, {
                headerText: "수요예측자료여부",
                dataField: "dem_fore_yn",
                width: "80",
                minWidth: "80",
                style: "aui-center",
            }, {
                headerText: "HOMI관리품여부",
                dataField: "homi_yn",
                width: "80",
                minWidth: "80",
                style: "aui-center",
            }, {
                headerText: "출하관리품여부",
                dataField: "out_mng_yn",
                width: "80",
                minWidth: "80",
                style: "aui-center",
            }, {
                headerText: "정비지시서 제외여부",
                dataField: "repair_yn",
                width: "80",
                minWidth: "80",
                style: "aui-center",
            }, {
                headerText: "포장단위",
                dataField: "part_pack_unit",
                width: "80",
                minWidth: "80",
                style: "aui-center",
            }, {
                headerText: "중량",
                dataField: "part_weight_kg",
                width: "80",
                minWidth: "80",
                style: "aui-center",
            }, {
                headerText: "발주단위",
                dataField: "order_unit",
                width: "80",
                minWidth: "80",
                style: "aui-center",
            }, {
                headerText: "구매리드타임",
                dataField: "part_pur_day_cnt",
                width: "80",
                minWidth: "80",
                style: "aui-center",
            }, {
                headerText: "최소LOT",
                dataField: "part_lot",
                width: "80",
                minWidth: "80",
                style: "aui-center",
            }, {
                headerText: "서비스%",
                dataField: "service_rate",
                width: "80",
                minWidth: "80",
                style: "aui-center",
            }, {
                headerText: "매입처",
                dataField: "deal_cust_no",
                width: "120",
                minWidth: "120",
                style: "aui-center",
            }, {
                headerText: "매입처2",
                dataField: "deal_cust_no2",
                width: "120",
                minWidth: "120",
                style: "aui-center",
            }, {
                headerText: "입고품질검사",
                dataField: "deal_ware_qual_ass",
                width: "80",
                minWidth: "80",
                style: "aui-center",
            }, {
                headerText: "금형관리 no",
                dataField: "deal_mold_cont_no_yn",
                width: "80",
                minWidth: "80",
                style: "aui-center",
            }, {
                headerText: "도면보유",
                dataField: "deal_floor_plan_yn",
                width: "80",
                minWidth: "80",
                style: "aui-center",
            }, {
                headerText: "최초등록일",
                dataField: "use_start_dt",
                width: "85",
                minWidth: "85",
                style: "aui-center",
            }, {
                headerText: "매출정지일",
                dataField: "sale_stop_dt",
                width: "85",
                minWidth: "85",
                style: "aui-center",
            }, {
                headerText: "원산지",
                dataField: "part_country_name",
                width: "70",
                minWidth: "70",
                style: "aui-center",
            }, {
                headerText: "호환모델",
                dataField: "part_model",
                width: "140",
                minWidth: "140",
                style: "aui-center",
            }, {
                headerText: "LIST PRICE",
                dataField: "list_price",
                width: "90",
                minWidth: "90",
                style: "aui-center",
            }, {
                headerText: "NET PRICE",
                dataField: "net_price",
                width: "90",
                minWidth: "90",
                style: "aui-center",
            }, {
                headerText: "SPECIAL",
                dataField: "special_price",
                width: "90",
                minWidth: "90",
                style: "aui-center",
            }, {
                headerText: "입고단가",
                dataField: "in_stock_price",
                width: "90",
                minWidth: "90",
                style: "aui-center",
            }, {
                headerText: "VIP판매가",
                dataField: "vip_price",
                width: "90",
                minWidth: "90",
                style: "aui-center",
            }, {
                headerText: "일반판매가",
                dataField: "cust_price",
                width: "90",
                minWidth: "90",
                style: "aui-center",
            }, {
                headerText: "전략가",
                dataField: "strategy_price",
                width: "90",
                minWidth: "90",
                style: "aui-center",
            }, {
                // [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
                // headerText: "대리점가",
                headerText: "위탁판매점가",
                dataField: "mng_agency_price",
                width: "90",
                minWidth: "90",
                style: "aui-center",
            }, {
                headerText: "최종 VIP판매가",
                dataField: "vip_sale_price",
                width: "90",
                minWidth: "90",
                style: "aui-center",
            }, {
                headerText: "최종 일반판매가",
                dataField: "sale_price",
                width: "90",
                minWidth: "90",
                style: "aui-center",
            }, {
                headerText: "수출적용환율",
                dataField: "apply_er_rate",
                width: "80",
                minWidth: "80",
                style: "aui-center",
            }, {
                headerText: "수출원가적용율",
                dataField: "cost_apply_rate",
                width: "80",
                minWidth: "80",
                style: "aui-center",
            }, {
                headerText: "수출적용원가",
                dataField: "cost_price",
                width: "90",
                minWidth: "90",
                style: "aui-center",
            }, {
                headerText: "수출가",
                dataField: "fob_export_price",
                width: "90",
                minWidth: "90",
                style: "aui-center",
            }];

            for (var i = 0; i < warehouseList.length; ++i) {
                var columnObj = {
                    headerText: warehouseList[i].warehouse_name,
                    dataField: warehouseList[i].warehouse_cd,
                    style: "aui-center",
                    width: "70",
                    editable: true,
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        var retStr = value;
                        return retStr;
                    }
                }
	            columnLayout.push(columnObj);
            }

            // 실제로 #grid_wrap에 그리드 생성
            auiGridExcel = AUIGrid.create("#auiGridExcel", columnLayout, gridPros);
            // 그리드 갱신
            AUIGrid.setGridData(auiGridExcel, []);

        }

        // 그리드 초기화
        function destroyGridExcel() {
            AUIGrid.destroy("#auiGridExcel");
            auiGridExcel = null;
        }

        function convertCase(element) {
            var str = JSON.stringify(element);

            var dataField = $M.getValue("code_value");
            var headerText = $("#code_value option:selected").text();

            str = str.replace(/\"상품코드\":/g, "\"origin_part_no\":");
            str = str.replace(/\"부품명\":/g, "\"origin_part_name\":");
            str = str.replace(/\"전체현재고\":/g, "\"origin_current_stock\":");
            str = str.replace(/\"매입단가\":/g, "\"origin_in_avg_price\":");
            str = str.replace(/\"현재\":/g, "\"old_data\":");
            str = str.replace(/\"적용데이터\":/g, "\"apply_data\":");

            element = JSON.parse(str);

            return element;
        }

        // 엑셀 파일 시트에서 파싱한 JSON 데이터 기반으로 그리드 동적 생성
        function createAUIGrid(csvStr) {
            if (AUIGrid.isCreated(auiGrid)) {
                AUIGrid.destroy(auiGrid);
                auiGrid = null;
            }

            csvStr = convertCase(csvStr);
            $("#total_cnt").html(csvStr.length);

            var gridProps = {
                rowIdField: "_$uid",
                softRemovePolicy: "exceptNew",
                wrapSelectionMove: true, // 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
                enableFilter: true,
                softRemoveRowMode: false,
            };

            var columnLayout = [
                {
	                headerText: "상품코드",
	                dataField: "origin_part_no",
	                width: "140",
	                minWidth: "130"
                },
                {
                    headerText: "부품명",
                    dataField: "origin_part_name",
                    width: "240",
                    minWidth: "230",
                    style: "aui-left"
                },
                {
                    headerText: "전체현재고",
                    dataField: "origin_current_stock",
                    width: "100",
                    minWidth: "100"
                },
                {
                    headerText: "평균매입가",
                    dataField: "origin_in_avg_price",
                    dataType: "numeric",
                    formatString: "#,##0",
                    width: "100",
                    minWidth: "90",
                    style: "aui-right"
                },
                {
                    headerText: "적용항목",
                    children: [
                        {
                            headerText: "현재",
                            dataField: "old_data",
                            width: "240",
                            minWidth: "230",
                        },
                        {
                            headerText: $("#code_value option:selected").text(),
                            dataField: "apply_data",
                            width: "240",
                            minWidth: "230"
                        },
                        {
                            dataField: "warehouse_cd",
                            visible : false
                        },

                    ]
                },
                {
                    // headerText: "list_price",
                    dataField: "calc_list_price",
                    visible : false
                },
                {
                    // headerText: "net_price",
                    dataField: "calc_net_price",
                    visible : false
                },
                {
                    // headerText: "special_price",
                    dataField: "calc_special_price",
                    visible : false
                },
                {
                    // headerText: "전략가",
                    dataField: "calc_strategy_price",
                    visible : false
                },
                {
                    // headerText: "입고단가",
                    dataField: "calc_in_stock_price",
                    visible : false
                },
                {
                    // headerText: "VIP판매가",
                    dataField: "calc_vip_price",
                    visible : false
                },
                {
                    // headerText: "최종VIP판매가",
                    dataField: "calc_vip_sale_price",
                    visible : false
                },
                {
                    // headerText: "일반판매가",
                    dataField: "calc_cust_price",
                    visible : false
                },
                {
                    // headerText: "최종일반판매가",
                    dataField: "calc_sale_price",
                    visible : false
                },
                {
                    // headerText: "대리점가",
                    dataField: "calc_mng_agency_price",
                    visible : false
                },
            ];

            // 실제로 #grid_wrap에 그리드 생성
            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridProps);

            // 그리드 갱신
            AUIGrid.setGridData(auiGrid, csvStr);

            $("#auiGrid").resize();
        }
    </script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
    <input type="hidden" name="s_warehouse_cd" id="s_warehouse_cd" value="">
    <div class="layout-box">
        <!-- contents 전체 영역 -->
        <div class="content-wrap">
            <div class="content-box">
                <div class="contents">
                    <!-- 기본 -->
                    <div class="search-wrap mt10">
                        <table class="table">
                            <colgroup>
                                <col width="60px">
                                <col width="180px">
                                <col width="80px">
                                <col width="60px">
                                <col width="100px">
                                <col width="300px">
                                <col width="75px">
                                <col width="60px">
                                <col width="75px">
                                <col width="">
                            </colgroup>
                            <tbody>
                            <tr>
                                <th>엑셀파일</th>
                                <td>
                                    <div class="form-row inline-pd">
                                        <div class="input-group col-auto">
                                            <input type="text" class="form-control width180px" id="file_name" name="file_name" readonly="readonly">
                                            <input type="file" name="fileSelector" id="fileSelector" style="display:none; width:5px;" accept=".xlsx" onchange="javascript:getCmaFileName(this);">
                                            <button type="button" class="btn btn-primary-gra width140px " name="btn_excel_upload" id="btn_excel_upload" onclick="javascript:goSearchFile();">액셀업로드</button>
                                        </div>
                                    </div>
                                </td>
                                <th>상품코드셀</th>
                                <td>
                                    <select class="form-control width120px" readonly="readonly">
                                        <option>A</option>
                                    </select>
                                </td>
                                <th>코드적용항목</th>
                                <td>
                                    <div class="form-row inline-pd">
                                        <div class="col-auto">
                                            <select class="form-control" id="code_value" name="code_value" onchange="javascaript:fnChangeGridData();">
                                                <option value="M.PART_NAME">부품명</option>
                                                <option value="M.PART_NO">부품번호</option>
                                                <option value="M.PART_NEW_NO">부품 신번호</option>
                                                <option value="M.PART_OLD_NO">부품 구번호</option>
                                                <option value="M.PART_NEW_EXCHANGE_CD">신번호_호환성코드</option>
                                                <option value="M.PART_OLD_EXCHANGE_CD">구번호_호환성코드</option>
                                                <option value="M.DEM_FORE_NO">수요예측 번호</option>
                                                <option value="M.PART_SAFE_STOCK">안전재고</option>
                                                <option value="M.PART_SAFE_STOCK2">안전재고2</option>
                                                <option value="M.MAKER_CD">메이커</option>
                                                <option value="M.PART_PRODUCTION_CD">생산구분코드</option>
                                                <option value="M.PART_MNG_CD">관리구분코드</option>
                                                <option value="M.PART_GROUP_CD">분류구분코드</option>
                                                <option value="MV.PART_MARGIN_CD">부품구분코드</option>
                                                <option value="MV.PART_OUTPUT_PRICE_CD">산출구분코드</option>
                                                <option value="M.DEM_FORE_YN">수요예측자료여부</option>
                                                <option value="M.HOMI_YN">HOMI 관리품여부</option>
                                                <option value="M.OUT_MNG_YN">출하관리품여부</option>
                                                <option value="M.APP_SALE_YN">고객앱판매여부</option>
                                                <option value="M.REPAIR_YN">정비지시서 제외여부</option>
                                                <option value="M.PART_PACK_UNIT">포장단위</option>
                                                <option value="M.PART_PACK_UNIT2">포장단위2</option>
<%--                                                <option value="M.PART_WEIGHT_KG">중량</option>--%>
                                                <option value="M.ORDER_UNIT">발주단위</option>
                                                <option value="M.ORDER_UNIT2">발주단위2</option>
                                                <option value="M.PART_PUR_DAY_CNT">구매리드타임</option>
                                                <option value="M.PART_PUR_DAY_CNT2">구매리드타임2</option>
                                                <option value="M.PART_LOT">최소 LOT</option>
                                                <option value="M.PART_LOT2">최소 LOT2</option>
                                                <option value="M.SERVICE_RATE">서비스%</option>
                                                <option value="M.SERVICE_RATE2">서비스%2</option>
                                                <option value="M.DEAL_CUST_NO">매입처</option>
                                                <option value="M.DEAL_CUST_NO2">매입처 2</option>
                                                <option value="M.DEAL_WARE_QUAL_ASS">입고품질검사</option>
                                                <option value="M.DEAL_WARE_QUAL_ASS2">입고품질검사2</option>
                                                <option value="M.DEAL_MOLD_CONT_NO_YN">금형관리 no</option>
                                                <option value="M.DEAL_MOLD_CONT_NO2_YN">금형관리 no2</option>
                                                <option value="M.DEAL_FLOOR_PLAN_YN">도면보유</option>
                                                <option value="M.DEAL_FLOOR_PLAN2_YN">도면보유2</option>
                                                <option value="M.AVG_EXCHANGE_CYCLE_YN">평균교환주기대상여부</option>
                                                <option value="M.SALE_STOP_DT">매출정지일</option>
                                                <option value="M.PART_COUNTRY_CD">원산지</option>
                                                <option value="M.PART_MODEL">호환모델</option>
                                                <option value="V.LIST_PRICE">LIST PRICE</option>
                                                <option value="V.LIST_PRICE2">LIST PRICE2</option>
<%--                                                <option value="V.NET_PRICE">NET PRICE</option>--%>
                                                <option value="V.SPECIAL_PRICE">SPECIAL</option>
                                                <option value="V.SPECIAL_PRICE2">SPECIAL2</option>
<%--                                                <option value="V.IN_STOCK_PRICE">입고단가</option>--%>
                                                <option value="V.STRATEGY_PRICE">전략가</option>
<%--                                                <option value="V.VIP_PRICE">VIP판매가</option>--%>
<%--                                                <option value="V.CUST_PRICE">일반판매가</option>--%>
                                                <%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
                                                <%--<option value="V.MNG_AGENCY_PRICE">대리점가</option>--%>
                                                <option value="V.MNG_AGENCY_PRICE">위탁판매점가</option>
<%--                                                <option value="V.VIP_SALE_PRICE">최종 VIP판매가</option>--%>
<%--                                                <option value="V.SALE_PRICE">최종 일반판매가</option>--%>
                                                <option value="S.SAFE_STOCK">적정재고</option> <%--22.12.12 Q&A 16965 적정재고 항목 추가 --%>
                                            </select>
                                        </div>
                                        <div class="col-auto">
                                            <input type="text" class="form-control" readonly="readonly" id="code_name" name="code_name">
                                        </div>
                                    </div>
                                </td>
                                <th>적용자료셀</th>
                                <td>
                                    <select class="form-control width60px" id="apply_cell" name="apply_cell">
                                        <c:forEach var="i" begin="66" end="90">
                                            <option value="<%=Character.toChars((Integer)pageContext.getAttribute("i"))%>"><%=Character.toChars((Integer) pageContext.getAttribute("i"))%></option>
                                        </c:forEach>
                                    </select>
                                </td>
                                <th>적용센터</th>
                                <td>
                                    <select class="form-control width75px" id="apply_center" name="apply_center" disabled="disabled">
                                        <option value="">- 선택 -</option>
                                        <c:forEach items="${codeMap['HOMI_WAREHOUSE']}" var="item">
                                            <option value="${item.code_value}">${item.code_name}</option>
                                        </c:forEach>
                                    </select>
                                </td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                    <!-- /기본 -->
                    <!-- 그리드 타이틀, 컨트롤 영역 -->
                    <div class="title-wrap mt10">
                        <h4>엑셀적용내역</h4>
                        <div class="btn-group">
                            <div class="right">
                                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                            </div>
                        </div>
                    </div>
                    <!-- /그리드 타이틀, 컨트롤 영역 -->
                    <div id="auiGridExcel" style="display:none;"></div>
                    <div id="auiGridSample" style="display:none;"></div>
                    <div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
                    <div id="auiGridSplit" style="display:none;"></div>

                    <!-- 그리드 서머리, 컨트롤 영역 -->
                    <div class="btn-group mt5">
                        <div class="left">
                            총 <strong class="text-primary" id="total_cnt">0</strong>건
                        </div>
                        <div class="right">
                            <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- /contents 전체 영역 -->
    </div>
</form>
</body>
</html>
