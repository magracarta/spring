<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > MMS파일관리 > null > MMS파일관리상세
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-03-16 10:48:19
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var auiGrid; // 장비
		var fileIdx = 1; // 오픈한 파일 idx
		var fileSeq1;
		var fileSeq2;
		var fileSeq3;
		var centerJson = ${orgCenterListJson}
		var makerJson = ${makerJson}
		var auiGrids = [{auiGrid:{}, value:"centerGrid", list:centerJson.map(function(center) {return {code: center.org_code,code_name: center.org_name}})}, // 센터
						{auiGrid:{}, value:"makerGrid", list:makerJson}]  // 메이커
						
		$(document).ready(function() {
			for (var i = 0; i < auiGrids.length; ++i) {
				createGrid(i); // 센터 메이커 그리드
			}
			createMachineGrid();
			fnInit();
		});
		
		window.onresize = function() {
			for (var i = 0; i < auiGrids.length; ++i) {
				fnResizeGrid(i);
			}
		};
		
		function fnInit() {
			var file1 = "${detail.file1.file_seq}";
			if (file1 == "") {
				file1 = null;
			} else {
				fileSeq1 = file1;
				$("#image_area1").empty();
				$("#image_area1").append(
					"<div class='attach-delete'><button type='button' class='btn btn-icon-lg text-light' onclick='javascript:fnRemoveFile(1)'><i class='material-iconsclose'></i></button></div>"
				   +"<img id='mmsImage' name='mmsImage' src='/file/"+fileSeq1+"' class='icon-profilephoto' tabindex=0  />");
				
			}
			var file2 = "${detail.file2.file_seq}";
			if (file2 == "") {
				file2 = null;
			} else {
				fileSeq2 = file2;
				$("#image_area2").empty();
				$("#image_area2").append(
					"<div class='attach-delete'><button type='button' class='btn btn-icon-lg text-light' onclick='javascript:fnRemoveFile(2)'><i class='material-iconsclose'></i></button></div>"
				   +"<img id='mmsImage' name='mmsImage' src='/file/"+fileSeq2+"' class='icon-profilephoto' tabindex=0  />");
			}
			var file3 = "${detail.file3.file_seq}";
			if (file3 == "") {
				file3 = null;
			} else {
				fileSeq3 = file3;
				$("#image_area3").empty();
				$("#image_area3").append(
					"<div class='attach-delete'><button type='button' class='btn btn-icon-lg text-light' onclick='javascript:fnRemoveFile(3)'><i class='material-iconsclose'></i></button></div>"
				   +"<img id='mmsImage' name='mmsImage' src='/file/"+fileSeq3+"' class='icon-profilephoto' tabindex=0  />");
			}
		}
		
		function fnResizeGrid(i) {
			setTimeout(function() {
				AUIGrid.resize(auiGrids[i].auiGrid);
				AUIGrid.resize(auiGrid);
			}, 1);
		}
		
		
		// 파일찾기 팝업
		function goSearchFile(idx) {
			fileIdx = idx;
			var param = {
					upload_type	: 'MMS',
					file_type : 'img',
					max_size : 300,
					open_yn : 'Y'
			};
			openFileUploadPanel("fnSetImage", $M.toGetParam(param));
		}
		
		// 팝업창에서 받아온 값
		function fnSetImage(result) {
			if (result != null && result.file_seq != null) {
				if (fileIdx == 1) {
					fileSeq1 = result.file_seq;
				} else if (fileIdx == 2) {
					fileSeq2 = result.file_seq;
				} else {
					fileSeq3 = result.file_seq;
				};
				// 이미지 그려주기 작업
				$("#image_area"+fileIdx).empty();
				$("#image_area"+fileIdx).append(
					"<div class='attach-delete'><button type='button' class='btn btn-icon-lg text-light' onclick='javascript:fnRemoveFile("+fileIdx+")'><i class='material-iconsclose'></i></button></div>"
				   +"<img id='mmsImage' name='mmsImage' src='/file/"+result.file_seq+"' class='icon-profilephoto' tabindex=0  />");				
			}
		}
		
		function fnRemoveFile(idx) {
			if (idx == 1) {
				fileSeq1 = null;
			} else if (idx == 2) {
				fileSeq2 = null;
			} else {
				fileSeq3 = null;
			}
			$("#image_area"+idx).empty();
			$("#image_area"+idx).append("<div class='no-img'><i class='icon-noimg'></i><div class='no-img-txt'>no images</div></div>");
		}
		
		function goModify() {
			if($M.validation(document.main_form) == false) {
				return;
			};
			if (fileSeq1 == null) {
				alert("첫번째 파일은 필수입니다.");
				return false;
			}
			var centerTemp = AUIGrid.getCheckedRowItemsAll("centerGrid");
			var centerArr = [];
			for (var i = 0; i < centerTemp.length; ++i) {
				centerArr.push(centerTemp[i].code);
			}
			var makerTemp = AUIGrid.getCheckedRowItemsAll("makerGrid");
			var makerArr = [];
			for (var i = 0; i < makerTemp.length; ++i) {
				makerArr.push(makerTemp[i].code);
			}
			var machineTemp = AUIGrid.getGridData(auiGrid);
			var machineDelTemp = AUIGrid.getRemovedItems(auiGrid);
			var machineDelArr = [];
			for (var i = 0; i < machineDelTemp.length; ++i) {
				machineDelArr.push(machineDelTemp[i].machine_plant_seq);
			}
			var machineArr = [];
			for (var i = 0; i < machineTemp.length; ++i) {
				if (!(machineDelArr.indexOf(machineTemp[i].machine_plant_seq) > -1)) {
					machineArr.push(machineTemp[i].machine_plant_seq);
				}
			}
			
			var param = {
					sms_attach_seq : ${inputParam.sms_attach_seq},
					sms_file_seq_1 : fileSeq1,
					sms_file_seq_2 : fileSeq2,
					sms_file_seq_3 : fileSeq3,
					title : $M.getValue("title"),
					sort_no : $M.getValue("sort_no"),
					use_yn : $M.getValue("use_yn"),
					remark : $M.getValue("remark"),
					center_org_code_str : $M.getArrStr(centerArr),
					maker_cd_str : $M.getArrStr(makerArr),
					machine_plant_seq_str : $M.getArrStr(machineArr) 
			};
			if (fileSeq3 != null && fileSeq2 == null) {
				param['sms_file_seq_2'] = fileSeq3;
				param['sms_file_seq_3'] = null;
			}
			console.log(param);
			$M.goNextPageAjaxSave("/comm/comm0113", $M.toGetParam(param), {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			alert("정상 처리되었습니다.");
		    			AUIGrid.removeSoftRows(auiGrid);
						AUIGrid.resetUpdatedItems(auiGrid);
						var total = AUIGrid.getGridData(auiGrid).length;
						$("#machineGrid_total_cnt").html(total);
					}
				}
			);
		}
		
		function goRemove() {
			$M.goNextPageAjaxRemove("/comm/comm0113/"+${inputParam.sms_attach_seq}+"/remove", '', {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			alert("정상 처리되었습니다.");
		    			fnClose();
		    			if (opener != null && opener.goSearch) {
		    				opener.goSearch();
		    			}
					}
				}
			);
		}
		
		function createGrid(i) {
			// 그리드 속성 설정
			var gridPros = {
				rowIdField : "code",
				//체크박스 출력 여부
				showRowCheckColumn: true,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				showStateColumn : true,
				editable : false,
			};
			var headerText = i == 0 ? "센터명" : "메이커";
			var columnLayout = [
				{
					dataField : "code",
					visible : false
				},
				{
					dataField : "code_name",
					headerText : headerText,
				}
			];
			auiGrids[i].auiGrid = AUIGrid.create(auiGrids[i].value, columnLayout, gridPros);
			AUIGrid.setGridData(auiGrids[i].auiGrid, auiGrids[i].list);
			AUIGrid.bind(auiGrids[i].auiGrid, "rowCheckClick", function( event ) {
			      var item = event.item;
			      var rowIndex = event.rowIndex;
			      var checked = event.checked;
			      console.log(checked);
			      var total = AUIGrid.getCheckedRowItemsAll(auiGrids[i].value).length;
				  $("#"+auiGrids[i].value+"_total_cnt").html(total);
			});
			AUIGrid.bind(auiGrids[i].auiGrid, "rowAllCheckClick", function( checked ) {
				var total = AUIGrid.getCheckedRowItemsAll(auiGrids[i].value).length;
				$("#"+auiGrids[i].value+"_total_cnt").html(total);
			});
			var list;
			if (i == 0) {
				list = ${detail.center}
				console.log(list);
			} else {
				list = ${detail.maker}
				console.log(list);
			}
			var tempArr = [];
			for (var j = 0; j < list.length; ++j) {
				if (i == 0) {
					tempArr.push(list[j].org_code);					
				} else {
					tempArr.push(list[j].maker_cd);
				}
			}
			$("#"+auiGrids[i].value+"_total_cnt").html(tempArr.length);
			console.log(tempArr);
			AUIGrid.addCheckedRowsByValue(auiGrids[i].value, "code", tempArr);
		}
		
		function createMachineGrid() {
			// 그리드 속성 설정
			var gridPros = {
				rowIdField : "_$uid",
				showStateColumn : true,
				editable : false,
			};
			var columnLayout = [
				{
					dataField : "machine_name",
					headerText : "모델명",
				},
				{
					dataField : "machine_plant_seq",
					visible : false
				},
				{
					width : "20%",
					headerText : "삭제",
					dataField : "removeBtn",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.removeRow(event.pid, event.rowIndex);								
							} else {
								AUIGrid.restoreSoftRows(auiGrid, "selectedIndex"); 
							};
							var total = AUIGrid.getGridData(auiGrid).length;
							$("#machineGrid_total_cnt").html(total);
						},
					},
					labelFunction : function(rowIndex, columnIndex, value,
							headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : false
				}
			];
			auiGrid = AUIGrid.create("auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData("auiGrid", ${detail.machine});
			var total = AUIGrid.getGridData(auiGrid).length;
			$("#machineGrid_total_cnt").html(total);
		}
		
		function fnSetModelResult(obj) {
			if (Array.isArray(obj) == true) {
				for (var i = 0; i < obj.length; ++i) {
					var isUnique = AUIGrid.isUniqueValue(auiGrid, "machine_plant_seq", obj[i].machine_plant_seq);
					if (isUnique == false) {
						alert("이미 등록된 모델이 있습니다.");
						return false;
					}
					var item = new Object();
					item.machine_name = obj[i].machine_name;
					item.machine_plant_seq = obj[i].machine_plant_seq;
					AUIGrid.addRow(auiGrid, item, 'last');
				}
			} else {
				var item = new Object();
				item.machine_name = obj.machine_name;
				item.machine_plant_seq = obj.machine_plant_seq;
				AUIGrid.addRow(auiGrid, item, 'last');
			}
			var total = AUIGrid.getGridData(auiGrid).length;
			$("#machineGrid_total_cnt").html(total);
		}
	
		function fnClose() {
			window.close();
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
			<div class="title-wrap">
				<h4>MMS파일상세</h4>
			</div>
<!-- 상단 폼테이블 -->					
			<table class="table-border mt5">
				<colgroup>
					<col width="100px">
					<col width="">
				</colgroup>
				<tbody>
					<tr>
						<th class="text-right essential-item">제목</th>
						<td>
							<input type="text" class="form-control essential-bg" style="width: 500px" datatype="string" maxlength="100" alt="제목" required="required" id="title" name="title" value="${detail.master.title}">
						</td>					
					</tr>
					<tr>
						<th class="text-right">내용</th>
						<td>
							<textarea class="form-control" style="height: 100px; width: 500px; resize: none;" id="remark" name="remark">${detail.master.remark}</textarea>
						</td>	
					</tr>
																
				</tbody>
			</table>					
<!-- /상단 폼테이블 -->
			<div class="row mt10">
				<div class="col-3">
<!-- 첨부파일 -->
					<div class="title-wrap">
						<h4>첨부파일</h4>
					</div>
					<div class="smstable-section-div rb">
<!--- no img -->								
								<div class="no-img-wrap" id="image_area1">
									<div class="no-img">
										<i class="icon-noimg"></i>
										<div class="no-img-txt">no images</div>
									</div>
								</div>
<!--- /no img -->
<!-- 첨부버튼-->								
								<div class="pt10 text-right">
									<button type="button" class="btn btn-primary-gra" onclick="javascript:goSearchFile(1)">파일찾기</button>
								</div>
<!-- /첨부버튼-->																
							</div>
							<div class="smstable-section-div">
								<div class="no-img-wrap" id="image_area2">
									<div class="no-img">
										<i class="icon-noimg"></i>
										<div class="no-img-txt">no images</div>
									</div>
								</div>
								<div class="pt10 text-right">
									<button type="button" class="btn btn-primary-gra" onclick="javascript:goSearchFile(2)">파일찾기</button>
								</div>
							</div>
							<div class="smstable-section-div">
								<div class="no-img-wrap" id="image_area3">
									<div class="no-img">
										<i class="icon-noimg"></i>
										<div class="no-img-txt">no images</div>
									</div>
								</div>
								<div class="pt10 text-right">
									<button type="button" class="btn btn-primary-gra" onclick="javascript:goSearchFile(3)">파일찾기</button>
								</div>
							</div>
<!-- /첨부파일 -->
				</div>
				<div class="col-3">
<!-- 사용센터 -->
					<div class="title-wrap">
						<h4>사용센터</h4>
					</div>
					<div class="smstable-section">
						<div id="centerGrid" style="margin-top: 5px; height: 454px;"></div>
						<div class="btn-group mt5">	
							<div class="left">
								총 <strong class="text-primary" id="centerGrid_total_cnt">0</strong>건
							</div>
						</div>
					</div>
<!-- /사용센터 -->			
				</div>
				<div class="col-3">
<!-- 메이커 -->
				<div class="title-wrap">
					<h4>메이커</h4>
				</div>
				<div class="smstable-section">
					<div id="makerGrid" style="margin-top: 5px; height: 454px;"></div>
					<div class="btn-group mt5">	
						<div class="left">
							총 <strong class="text-primary" id="makerGrid_total_cnt">0</strong>건
						</div>
					</div>
				</div>	
<!-- /메이커 -->		
			</div>
			<div class="col-3">
<!-- 모델 -->
				<div class="title-wrap">
					<h4>모델</h4>
				</div>
				<div class="smstable-section">
					<div class="smstable-search" style="height: 24px !important">
						<button type="button" class="btn btn-dark" onclick="javascript:openSearchModelPanel('fnSetModelResult', 'Y')">추가</button>
					</div>
					<div id="auiGrid" style="margin-top: 5px; height: 430px;"></div>
					<div class="btn-group mt5">	
						<div class="left">
							총 <strong class="text-primary" id="machineGrid_total_cnt">0</strong>건
						</div>
					</div>
				</div>	
<!-- /모델 -->		
			</div>
		</div>
<!-- 그리드 서머리, 컨트롤 영역 -->
		<div class="btn-group mt10">						
			<div class="right">
<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
			</div>
		</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
	</div>
</div>
<input type="hidden" id="use_yn" name="use_yn" value="${detail.master.use_yn}">
<input type="hidden" id="sort_no" name="sort_no" value="${detail.master.sort_no}">
<input type="hidden" id="sort_no" name="sort_no" value="${detail.master.smsFileSeq}">
</form>
</body>
</html>