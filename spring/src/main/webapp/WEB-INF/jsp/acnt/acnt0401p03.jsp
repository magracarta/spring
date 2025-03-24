<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 정산 > 장비입고관리-통관 > null > 부대비용관리
-- 작성자 : 김상덕
-- 최초 작성일 : 2020-04-08 18:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	var addData = ${addList}
	
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
			fnInit();
		});
		
		function fnInit() {
// 			console.log("addData : ", addData);
// 			if (addData.length != 0) {
// 				for (var i = 0; i < addData.length; i++) {
// 					var item = {
// 							machine_lc_no : addData[i].machine_lc_no,
// 							seq_no : addData[i].seq_no,
// 							machine_ship_mng_cost_name : addData[i].machine_ship_mng_cost_name,
// 							pass_proc_date : addData[i].pass_proc_date
// 					}
					
					
// 				}
// 			}
		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				// No. 제거
				showRowNumColumn: true,
				showStateColumn : true,
				editable : true,
				showFooter : true,
				footerPosition : "top",
				enableMovingColumn : false
			};
			var columnLayout = [
				{ 
					dataField : "machine_ship_mng_cost_cd", 
					visible : false
				},
				{ 
					dataField : "machine_lc_no", 
					visible : false
				},
				{ 
					dataField : "seq_no", 
					visible : false
				},
				{ 
					dataField : "add_item_name", 
					visible : false
				},
				{ 
					dataField : "machine_seq", 
					visible : false
				},
				{
					headerText : "처리일자", 
					dataField : "pass_proc_date", 
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "28%",
					style : "aui-center",
					editable : false
				},
				{ 
					headerText : "금액", 
					dataField : "amt", 
					width : "20%",
					dataType : "numeric",
					allowNegative : true,
					style : "aui-right aui-editable",
					editable : true,
					editRenderer : {
					      type : "InputEditRenderer",
					      onlyNumeric : true,
					      allowNegative : true,
					      // 에디팅 유효성 검사
					      validator : AUIGrid.commonValidator
					}
				},
				{ 
					headerText : "적요", 
					dataField : "machine_ship_mng_cost_name", 
					width : "40%",
					style : "aui-left aui-editable",
					editable : true
				},
				{
					
					headerText : "삭제",
					dataField : "deleteBtn",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							// 추가 부대비용건만 삭제 가능
							if (event.item.machine_lc_no != "") {
								var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
								if (isRemoved == false) {
									AUIGrid.removeRow(event.pid, event.rowIndex);		
								} else {
									AUIGrid.restoreSoftRows(auiGrid, "selectedIndex"); 
								}
							}
						}
					},
					labelFunction : function(rowIndex, columnIndex, value,
							headerText, item) {
						return '삭제'
					},
		
					style : "aui-center",
					editable : true
				}				
			];
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "pass_proc_date",
					style : "aui-center aui-footer",
				}, 
				{
					dataField : "amt",
					positionField : "amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			AUIGrid.setGridData(auiGrid, ${list});
			$("#total_cnt").html(${total_cnt});
			
			AUIGrid.bind(auiGrid, "cellEditBegin", function (event) {
				if (event.dataField == "machine_ship_mng_cost_name") {
					if (event.item.machine_lc_no != "") {
						return true;
					}
				}
				if (event.dataField == "amt") {
					return true;
				}
				// 추가된 행 아이템인지 조사하여 추가된 행인 경우만 에디팅 진입 허용
				if (AUIGrid.isAddedById(event.pid, event.item._$uid)) {
					return true;
				} else {
					return false;
				}
			});
			
			$("#auiGrid").resize();
		}
	
		// 닫기
		function fnClose() {
			window.close();
		}
		
		function fnCheckGridEmpty() {
			return AUIGrid.validateGridData(auiGrid, ["amt", "machine_ship_mng_cost_name"], "필수 항목은 반드시 값을 입력해야합니다.");
		}
		
		function goSave() {
			if(isValid() == false) {
				return;
			}
			
			var addGridData = AUIGrid.getAddedRowItems(auiGrid);  // 추가내역
			var changeGridData = AUIGrid.getEditedRowItems(auiGrid); // 변경내역
			var removeGridData = AUIGrid.getRemovedItems(auiGrid); // 삭제내역
			
			console.log("추가내역 : ", addGridData);
			console.log("변경내역 : ", changeGridData);
			console.log("삭제내역 : ", removeGridData);
			
			// 추가 부대비용 내역
			var machineLcNoArr = [];
			var seqNoArr = [];
			var addItemNameArr = [];
			var amtArr = [];
			
			// 기존 부대비용 내역
			var machineSeqArr = [];
			var machineShipMngCostCdArr = [];
// 			var amtArr = [];
			var cmdArr = [];
			
			for (var i = 0; i < addGridData.length; i++) {
				machineLcNoArr.push(addGridData[i].machine_lc_no);
				seqNoArr.push(addGridData[i].seq_no);
				addItemNameArr.push(addGridData[i].machine_ship_mng_cost_name);
				amtArr.push(addGridData[i].amt);
				machineSeqArr.push("");
				machineShipMngCostCdArr.push("");
				cmdArr.push("C");
			}
			
			for (var i = 0; i < changeGridData.length; i++) {
				machineLcNoArr.push("");
				seqNoArr.push("");
				addItemNameArr.push("");
				machineSeqArr.push(changeGridData[i].machine_seq);
				machineShipMngCostCdArr.push(changeGridData[i].machine_ship_mng_cost_cd);
				amtArr.push(changeGridData[i].amt);
				cmdArr.push("U");
			}
			
			for (var i = 0; i < removeGridData.length; i++) {
				machineLcNoArr.push(removeGridData[i].machine_lc_no);
				seqNoArr.push(removeGridData[i].seq_no);
				addItemNameArr.push(removeGridData[i].machine_ship_mng_cost_name);
				amtArr.push(removeGridData[i].amt);
				machineSeqArr.push("");
				machineShipMngCostCdArr.push("");
				cmdArr.push("D");
			}
			
			var option = {
					isEmpty : true
			};
			
 			var param = {
 					machine_lc_no_str : $M.getArrStr(machineLcNoArr, option),
 					seq_no_str : $M.getArrStr(seqNoArr, option),
 					add_item_name_str : $M.getArrStr(addItemNameArr, option),
 					amt_str : $M.getArrStr(amtArr, option),
 					machine_seq_str : $M.getArrStr(machineSeqArr, option), 
 					machine_ship_mng_cost_cd_str : $M.getArrStr(machineShipMngCostCdArr, option), 
 					cmd_str : $M.getArrStr(cmdArr, option), 
			}
			console.log("param : ", param);
 			
			$M.goNextPageAjaxSave(this_page + "/save", $M.toGetParam(param) , {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			alert("저장이 완료되었습니다. \n산출원가 및 부대비용 배분을 다시 해주세요.");
		    			window.opener.location.reload();
						fnClose();
					}
				}
			);			
		}
		
		function fnAdd() {
			if(isValid()) {
				var row = new Object();
				row.pass_proc_date = "${inputParam.s_current_dt}";
				row.amt = '';
	 			row.machine_ship_mng_cost_name = '';
	 			row.machine_lc_no = $M.getValue("machine_lc_no");;
	 			row.seq_no = 0;
	 			row.add_item_name = '';
				AUIGrid.addRow(auiGrid, row, "last");
			}
		}
		
		// 그리드 빈값 체크
		function isValid() {
			var msg = "필수 항목은 반드시 값을 입력해야 합니다.";
			// 기본 필수 체크
			var reqField = ["pass_proc_date", "amt", "machine_ship_mng_cost_name"];
			return AUIGrid.validateGridData(auiGrid, reqField, msg);
		}
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" name="machine_lc_no" value="${inputParam.machine_lc_no}">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블 -->					
			<div>
				<div class="title-wrap">
					<h4>부대비용관리</h4>
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
			</div>
<!-- /폼테이블-->					
			<div class="btn-group mt10">	
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>	
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>