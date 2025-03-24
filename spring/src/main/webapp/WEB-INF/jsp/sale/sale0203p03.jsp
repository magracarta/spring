<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 장비입고-LC Open 선적 > 장비대장관리-선적 > 컨테이너생성
-- 작성자 : 황빛찬
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
			
		var list = ${list}

		var dtList = []; // 시간:분 드롭다운리스트

		// 첨부파일의 index 변수
		var fileIndex = 1;
		// 첨부할 수 있는 파일의 개수
		var fileCount = 5;
		
		$(document).ready(function() {
			createAUIGrid();

			// 시간,분 계산 로직
			fnTimeCalculation();

			<c:forEach var="list" items="${fileList}">fnPrintFile('${list.file_seq}', '${list.file_name}');</c:forEach>

		});

		// 파일추가
		function fnAddFile(){
			if($("input[name='file_seq']").size() >= fileCount) {
				alert("파일은 " + fileCount + "개만 첨부하실 수 있습니다.");
				return false;
			}

			var fileSeqArr = [];
			var fileSeqStr = "";
			$("[name=file_seq]").each(function() {
				fileSeqArr.push($(this).val());
			});

			fileSeqStr = $M.getArrStr(fileSeqArr);

			var fileParam = "";
			if("" != fileSeqStr) {
				fileParam = '&file_seq_str='+fileSeqStr;
			}

			openFileUploadMultiPanel('setFileInfo', 'upload_type=LC&file_type=both&total_max_count=5'+fileParam);
		}

		// 첨부파일 출력 (멀티)
		function fnPrintFile(fileSeq, fileName) {
			var str = '';
			str += '<div class="table-attfile-item con_file_' + fileIndex + ' fileDiv"style="float:left; display:block;">';
			str += '<a href="javascript:fileDownload(' + fileSeq + ');" style="color: blue; vertical-align: middle;">' + fileName + '</a>&nbsp;';
			str += '<input type="hidden" name="file_seq" value="' + fileSeq + '"/>';
			str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveFile(' + fileIndex + ', ' + fileSeq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
			str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
			str += '</div>';
			$('.con_file_div').append(str);
			fileIndex++;
		}

		// 파일세팅
		function setFileInfo(result) {
			$(".fileDiv").remove(); // 파일영역 초기화

			var fileList = result.fileList;  // 공통 파일업로드(다중) 에서 넘어온 file list
			for (var i = 0; i < fileList.length; i++) {
				fnPrintFile(fileList[i].file_seq, fileList[i].file_name);
			}
		}

		// 첨부파일 삭제
		function fnRemoveFile(fileIndex, fileSeq) {
			var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
			if (result) {
				$(".con_file_" + fileIndex).remove();
			} else {
				return false;
			}
		}

		// 첨부서류 일괄다운로드
		function fnFileAllDownload() {
			var fileSeqArr = [];
			$("[name=file_seq]").each(function () {
				fileSeqArr.push($(this).val());
			});

			var paramObj = {
				'file_seq_str' : $M.getArrStr(fileSeqArr)
			}

			fileDownloadZip(paramObj);
		}
		
		function createAUIGrid() {
			var gridPros = {
				// rowIdField 설정
				rowIdField : "_$uid",
				editable : true,
				showStateColumn : true,
				// rowNumber 
				showRowNumColumn: true,
			};
			var columnLayout = [
				{ 
					dataField : "machine_lc_no", 
					visible : false
				},
				{ 
					dataField : "container_seq", 
					visible : false
				},
				{
					dataField : "car_date", 
					visible : false
				},
				{
					dataField : "container_status_cd", 
					visible : false
				},
// 				{
// 					dataField : "machine_seq", 
// 					visible : false
// 				},
				{
					headerText : "컨테이너명", 
					dataField : "container_name", 
					style : "aui-center aui-editable",
				},
				{
					headerText : "선적일자", 
					dataField : "ship_dt", 
					dataType : "date",  
					style : "aui-center aui-editable",					
					dataInputString : "yyyymmdd",
					formatString : "yyyy-mm-dd",
					editable : true,
					editRenderer : {
						type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
						defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
						onlyCalendar : true, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
						maxlength : 8,
						onlyNumeric : true, // 숫자만
						validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
							return fnCheckDate(oldValue, newValue, rowItem);
						},
						showEditorBtnOver : true
					}
				},
				{
					headerText : "입항예정일", 
					dataField : "port_plan_dt", 
					dataType : "date",  
					style : "aui-center aui-editable",					
					dataInputString : "yyyymmdd",
					formatString : "yyyy-mm-dd",
					editable : true,
					editRenderer : {
						type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
						defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
						onlyCalendar : true, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
						maxlength : 8,
						onlyNumeric : true, // 숫자만
						validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
							return fnCheckDate(oldValue, newValue, rowItem);
						},
						showEditorBtnOver : true
					}
				},
				{
					headerText : "배차일자", 
					dataField : "car_date1", 
					dataType : "date",  
					style : "aui-center aui-editable",					
					dataInputString : "yyyymmdd",
					formatString : "yyyy-mm-dd",
					editable : true,
					editRenderer : {
						type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
						defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
						onlyCalendar : true, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
						maxlength : 8,
						onlyNumeric : true, // 숫자만
						validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
							return fnCheckDate(oldValue, newValue, rowItem);
						},
						showEditorBtnOver : true
					}
				},
				{
					headerText : "배차일시",
					dataField : "car_date2",
					style : "aui-center aui-editable",
					editRenderer : {				
						type : "DropDownListRenderer",
						list : dtList,
					}
				},
				{
					headerText : "배차기사명", 
					dataField : "driver_name", 
					style : "aui-center aui-editable"
				},
				{
					headerText : "전화번호", 
					dataField : "driver_hp_no", 
					style : "aui-center aui-editable",
					editRenderer : {
					      type : "InputEditRenderer",
					      onlyNumeric : true,
					      // 에디팅 유효성 검사
					      validator : AUIGrid.commonValidator
					},
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					     if(String(value).length > 0) {
					         // 전화번호에 대시 붙이는 정규식으로 표현
					         return value.replace(/(^02.{0}|^01.{1}|[0-9]{3})([0-9]+)([0-9]{4})/,"$1-$2-$3"); 
					     }
					     return value; 
					}
				},
				{
					headerText : "센터확정여부",
					dataField : "center_confirm_yn",
					style : "aui-center",
					editable : false,
				},
				{ 
					headerText : "삭제", 
					dataField : "removeBtn",
					width : "6%", 
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							console.log(event);
							// 센터확정여부가 N 인 것만 삭제가능.
							if (event.item.center_confirm_yn == "Y") {
								alert("센터확정 된 컨테이너는 삭제가 불가능합니다.");
								return;
							}

							// 센터확정요청이 N 인 것만 삭제가능.
							if (event.item.center_confirm_req_yn == "Y") {
								alert("입고센터 요청을 취소하고 진행 해 주세요.");
								return;
							}
								

							// 컨테이너에 등록된 차대번호가 없을경우에만 삭제가능
							if (event.item.container_status_cd != "00") {
								alert("차대번호 등록된 컨테이너는 삭제가 불가능합니다.");
								return;
							}
							
							var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.removeRow(event.pid, event.rowIndex);		
							} else {
								AUIGrid.restoreSoftRows(auiGrid, "selectedIndex"); 
							}
						},
					},
					labelFunction : function(rowIndex, columnIndex, value,
							headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : false,
				}
			]

			// 실제로 #grid_wrap 에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, ${list});
			// 배차일자가 선택되지 않으면 배차일시 에디팅 불가
			AUIGrid.bind(auiGrid, "cellEditBegin", function (event) {
				if (event.dataField == "car_date2") {
// 					console.log("event : ", event);
					if (event.item.car_date1 == null || event.item.car_date1 == "" ) {
						return false;
					}	
				}
				
				// 센터확정여부가 Y인 row는 에디팅 불가
				// if (event.item.center_confirm_yn == "Y") {
				// 	return false;
				// }
			});
			
			AUIGrid.bind(auiGrid, "cellEditEnd", function (event) {
				if (event.dataField == "car_date1" || event.dataField == "car_date2") {
// 					console.log("event : ", event);
					var str = event.item.car_date1 + ' ' + event.item.car_date2;
					AUIGrid.updateRow(auiGrid, {"car_date" : str}, event.rowIndex);
				}
			});
			
			$("#auiGrid").resize();
	
		}
		
		// 컨테이너 추가
		function fnAddContainer() {
			var colIndex = AUIGrid.getColumnIndexByDataField(auiGrid, "container_seq");
			fnSetCellFocus(auiGrid, colIndex, "container_seq");
			var gridData = AUIGrid.getGridData(auiGrid);
			
			var item = new Object();
			if(fnCheckGridEmpty(auiGrid)) {
				// 배차일자에 입력값이 없으면 배차일시도 입력 하지 못하도록 벨리데이션 체크
				for (var i = 0; i < gridData.length; i++) {
					console.log(gridData[i].car_date1);
					if (gridData[i].car_date1 != null && gridData[i].car_date2 == null
							|| gridData[i].car_date1 != "" && gridData[i].car_date2 == "") {
						alert("배차일시를 입력해주세요.");
						return false;
					}
				}
				
	    		item.machine_lc_no = "${inputParam.machine_lc_no}",
	    		item.container_seq = "0",
	    		item.container_name = "",
// 	    		item.ship_dt = null,
// 	    		item.port_plan_dt = null,
	    		item.ship_dt = $M.getValue("etd"),
	    		item.port_plan_dt = $M.getValue("eta"),
	    		item.car_date = null,
	    		item.car_date1 = null,
	    		item.car_date2 = null,
	    		item.driver_name = "",
	    		item.driver_hp_no = "",
	    		item.driver_name_format = "",
	    		item.driver_hp_no_format = "",
	    		item.container_status_cd = "00",
// 	    		item.machine_seq = "",
	    		AUIGrid.addRow(auiGrid, item, 'last');
			}
		}
		
		// 컨테이너 추가 벨리데이션
		function fnCheckGridEmpty() {
			return AUIGrid.validateGridData(auiGrid, ["container_name", "ship_dt", "port_plan_dt"], "필수 항목은 반드시 값을 입력해야합니다.");
		}

		//팝업 끄기
		function fnClose() {
			window.close(); 
		}
		
		function goSave() {
			if(fnCheckGridEmpty(auiGrid) == false) {
				return;
			}
			
			var gridData = AUIGrid.getGridData(auiGrid);
			var sendPaperYnCnt = 0;

			// 배차일자에 입력값이 없으면 배차일시도 입력 하지 못하도록 벨리데이션 체크
			for (var i = 0; i < gridData.length; i++) {
				if (gridData[i].center_confirm_yn == "Y") {
					sendPaperYnCnt++;
				}

				if ((gridData[i].car_date1 != null && gridData[i].car_date2 == null) ||
						(gridData[i].car_date1 != "" && gridData[i].car_date2 == "")) {
					alert("배차일시를 입력해주세요.");
					return;
				} 
			}

			if (confirm("저장 하시겠습니까 ?") == false) {
				return;
			}

			var idx = 1;
			$("input[name='file_seq']").each(function() {
				var str = 'con_file_seq_' + idx;
				if ($(this).attr("id") == undefined || $(this).attr("id") == '') {
					$M.setValue(str, $(this).val());
				}
				idx++;
			});
			for(; idx <= fileCount; idx++) {
				$M.setValue('con_file_seq_' + idx, 0);
			}

			var container_seq = [];
            var container_name = [];
            var machine_lc_no = [];
            var ship_dt = [];
            var port_plan_dt = [];
            var car_date = [];
            var driver_name = [];
            var driver_hp_no = [];
            var container_cmd = [];
			
			var addRows = AUIGrid.getAddedRowItems(auiGrid);
			var editRows = AUIGrid.getEditedRowItems(auiGrid);
			var removeRows = AUIGrid.getRemovedItems(auiGrid);
			
			var frm = document.main_form;
			frm = $M.toValueForm(document.main_form);
			
			for (var i = 0; i < addRows.length; i++) {
				container_seq.push(addRows[i].container_seq);
				container_name.push(addRows[i].container_name);
				machine_lc_no.push(addRows[i].machine_lc_no);
				ship_dt.push(addRows[i].ship_dt);
				port_plan_dt.push(addRows[i].port_plan_dt);
				car_date.push(addRows[i].car_date);
				driver_name.push(addRows[i].driver_name);
				driver_hp_no.push(addRows[i].driver_hp_no);
				container_cmd.push("C");
			}
			
			for (var i = 0; i < editRows.length; i++) {
				container_seq.push(editRows[i].container_seq);
				container_name.push(editRows[i].container_name);
				machine_lc_no.push(editRows[i].machine_lc_no);
				ship_dt.push(editRows[i].ship_dt);
				port_plan_dt.push(editRows[i].port_plan_dt);
				car_date.push(editRows[i].car_date1 + editRows[i].car_date2);
				driver_name.push(editRows[i].driver_name);
				driver_hp_no.push(editRows[i].driver_hp_no);
				container_cmd.push("U");
			}
			
			for (var i = 0; i < removeRows.length; i++) {
				container_seq.push(removeRows[i].container_seq);
				container_name.push(removeRows[i].container_name);
				machine_lc_no.push(removeRows[i].machine_lc_no);
				ship_dt.push(removeRows[i].ship_dt);
				port_plan_dt.push(removeRows[i].port_plan_dt);
// 				car_date.push(removeRows[i].car_date1 + ' ' + removeRows[i].car_date2);
				car_date.push(removeRows[i].car_date1 + removeRows[i].car_date2);
				driver_name.push(removeRows[i].driver_name);
				driver_hp_no.push(removeRows[i].driver_hp_no);
				container_cmd.push("D");
			}

			var option = {
					isEmpty : true
			};

			$M.setValue(frm, "container_seq_str", $M.getArrStr(container_seq, option));
			$M.setValue(frm, "container_name_str", $M.getArrStr(container_name, option));
			$M.setValue(frm, "machine_lc_no_str", $M.getArrStr(machine_lc_no, option));
			$M.setValue(frm, "ship_dt_str", $M.getArrStr(ship_dt, option));
			$M.setValue(frm, "port_plan_dt_str", $M.getArrStr(port_plan_dt, option));
			$M.setValue(frm, "car_date_str", $M.getArrStr(car_date, option));
			$M.setValue(frm, "driver_name_str", $M.getArrStr(driver_name, option));
			$M.setValue(frm, "driver_hp_no_str", $M.getArrStr(driver_hp_no, option));
			$M.setValue(frm, "container_cmd_str", $M.getArrStr(container_cmd, option));
			
			$M.goNextPageAjax(this_page +"/save", frm, {method : 'POST', async : false},
   				function(result) {
   					if(result.success) {
   						alert("저장이 완료되었습니다.");

						if (sendPaperYnCnt > 0) {
							if(confirm("쪽지를 전송하시겠습니까?")) {
								goSendPaper();
							} else {
								window.opener.location.reload();
								location.reload();
							}
						} else {
							window.opener.location.reload();
							location.reload();
						}
   					};
   				}
   			);
		}

		// 컨테이너 저장 후 쪽지 전송
		function goSendPaper() {
			var param = {
				"machine_lc_no" : $M.getValue("machine_lc_no")
			}
			$M.goNextPageAjax(this_page + "/search/paperInfo", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						console.log("result : ", result);
						var obj = {
							"paper_contents" : result.paperSendMsg,
							"receiver_mem_no_str" : result.receiverMemStr,
							"ref_key" : $M.getValue("machine_lc_no"),
							"menu_seq" : "724",
							"pop_get_param" : "machine_lc_no="+$M.getValue("machine_lc_no")
						}

						openSendPaperPanel(obj);
						window.opener.location.reload();
						location.reload();
					};
				}
			);
		}
		
		// 시간,분 계산 로직
		function fnTimeCalculation() {
			var time = 0; // 시간
			var minute = 0;  // 분
			var strTime = "";
			var strMinute = "";
			var result = "";  // 결과
			
			for (var i = 0; i < 48; i++) {
				if (minute < 60) {
					strTime = time;
					strMinute = minute;
					
					if (strTime < 10) {
						strTime = '0' + strTime;
					}
					
					if (strMinute != 30) {
						strMinute = '0' + strMinute;
					}
					
					result = strTime + ':' + strMinute;
				} else {
					time = time + 1;
					minute = 0;
					strTime = time;
					strMinute = minute;
					
					if (strTime < 10) {
						strTime = '0' + strTime;
					}
					
					if (strMinute != 30) {
						strMinute = '0' + strMinute;
					}
					
					result = strTime + ':' + strMinute;
				} 
				minute += 30;
				dtList.push(result);
			}
		}

	</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
<input type="hidden" id="etd" name="etd" value="${map.etd}">
<input type="hidden" id="eta" name="eta" value="${map.eta}">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp" />
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	
			<div class="title-wrap">
				<div class="doc-info" style="flex: 1;">				
					<h4>컨테이너목록</h4>		
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>	
				</div>		
			</div>
			<div id="auiGrid" style="margin-top: 5px;"></div>
			<table class="table-border" style="margin-top : 10px;">
				<tbody>
					<tr>
						<th class="text-right">배차정보</th>
						<td colspan="5.5" style="border-right: white;">
							<div class="table-attfile con_file_div" style="width:100%;">
								<div class="table-attfile" style="float:left">
									<button type="button" class="btn btn-primary-gra mr10" name="fileAddBtn" id="fileAddBtn" onclick="javascript:fnAddFile();">파일찾기</button>
								</div>
							</div>
						</td>
						<td style="border-left: white;">
							<div class="table-attfile" style="display: inline-block; margin: 0 5px;  float: right;">
								<button type="button" class="btn btn-primary-gra mr10"  onclick="javascript:fnFileAllDownload();">파일일괄다운로드</button>
							</div>
						</td>
					</tr>
				</tbody>
			</table>
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5" style="margin-top: 50px;">						
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>	
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
<!-- /팝업 -->
<input type="hidden" id="con_file_seq_1" name="con_file_seq_1" value="${list2[0].con_file_seq_1 }"/>
<input type="hidden" id="con_file_seq_2" name="con_file_seq_2" value="${list2[0].con_file_seq_2 }"/>
<input type="hidden" id="con_file_seq_3" name="con_file_seq_3" value="${list2[0].con_file_seq_3 }"/>
<input type="hidden" id="con_file_seq_4" name="con_file_seq_4" value="${list2[0].con_file_seq_4 }"/>
<input type="hidden" id="con_file_seq_5" name="con_file_seq_5" value="${list2[0].con_file_seq_5 }"/>
<input type="hidden" id="machine_lc_no" name="machine_lc_no" value="${inputParam.machine_lc_no}"/>
</form>
</body>
</html>