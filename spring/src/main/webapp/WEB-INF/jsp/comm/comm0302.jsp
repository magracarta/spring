<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 영업 > 장비기본지급품관리 > null > null
-- 작성자 : 김상덕
-- 최초 작성일 : 2020-03-27 16:27:52
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	$(document).ready(function() {
		createAUIGridLeft();
		createAUIGridRight();
	});
	
	function fnDownloadExcel() {
		fnExportExcel(auiGridLeft, "장비기본지급품관리");
	}
	
	function fnExcelDownSec() {
		fnExportExcel(auiGridRight, "장비기본지급품옵션");
	}
	
	function enter(fieldObj) {
       var field = [ "s_maker_cd", "s_machine_name" ];
       $.each(field, function() {
          if (fieldObj.name == this) {
             goSearch(document.main_form);
          }
       });
    }
	
	function createAUIGridLeft() {
		var gridPros = {
			showRowNumColumn: true,
			enableSorting : true,
			rowIdField : "machine_plant_seq"
		};
		var columnLayout = [
			{ 
				dataField : "machine_plant_seq", 
				visible : false
			},
			{ 
				headerText : "메이커", 
				dataField : "maker_name", 
				style : "aui-center",
				width : "20%"
			},
			{ 
				headerText : "모델", 
				dataField : "machine_name",
				style : "aui-center aui-link",
				width : "20%"
			},
			{ 
				headerText : "품명", 
				dataField : "item_names", 
				style : "aui-left",
				width : "60%"
			}
		];
		auiGridLeft = AUIGrid.create("#auiGridLeft", columnLayout, gridPros);
		AUIGrid.bind(auiGridLeft, "cellClick", function(event) {
			var machine_plant_seq = event.item.machine_plant_seq;
			setMachinePlantSeq(machine_plant_seq);
			goSearchBasicItem(machine_plant_seq);
		});
		AUIGrid.setGridData(auiGridLeft, []);
	}
		
	function createAUIGridRight() {
		var gridPros = {
			showRowNumColumn: true,
			enableSorting : false,
			rowIdField : "seq_no"
		};
		var columnLayout = [
			{ 
				headerText : "품명", 
				dataField : "item_name", 
				style : "aui-left",
				width : "15%"
			},
			{ 
				headerText : "비고", 
				dataField : "remark",
				style : "aui-left",
				width : "70%"
			},
			{ 
				headerText : "수량", 
				dataField : "qty",
				style : "aui-center",
				dataType : "numeric",
				width : "5%"
			},
			{ 
				headerText : "정렬순서", 
				dataField : "sort_no",
				style : "aui-center",
				width : "10%"
			},
			{ 
				dataField : "seq_no",
				visible : false
			},
			{ 
				dataField : "file_seq",
				visible : false
			},
			{ 
				dataField : "origin_file_name",
				visible : false
			}
		];
		auiGridRight = AUIGrid.create("#auiGridRight", columnLayout, gridPros);
		AUIGrid.bind(auiGridRight, "cellClick", function(event) {
			setSeqNo(event.item.seq_no);
			$M.setValue("item_name", event.item.item_name);
			$M.setValue("qty", event.item.qty);
			$M.setValue("sort_no", event.item.sort_no);
			$M.setValue("remark", event.item.remark);
			// 파일 있으면 파일정보 표시
			if ("" == event.item.file_seq || "" == event.item.origin_file_name) {
				showFileSearchTd();
			} else {
				var file_info = {
					"file_seq" : event.item.file_seq
					, "file_name" : event.item.origin_file_name
				};
				setFileInfo(file_info);
				showFileNameTd();
			}
		});
		// 그리드 갱신
		AUIGrid.setGridData(auiGridRight, []);
	}
	
	// 장비 기본지급품 저장
	function goSave() {
		if(getMachinePlantSeq() == "") {
			alert("장비모델을 선택해주세요.");
			return;
		}
		var frm = document.main_form;
		if($M.validation(frm) == false) { 
			return;
		}
		$M.goNextPageAjaxSave(this_page + '/save', $M.toValueForm(frm) , {method : 'POST'},
			function(result) {
				if(result.success) {
					goSearchBasicItem(getMachinePlantSeq());
				}
			}
		);
	}
	
	// 삭제
	function goRemove() {
		if(getMachinePlantSeq() == "") {
			alert("장비모델을 선택해주세요.");
			return;
		}
		// 선택한 행 정보
		var selectedRowItems = AUIGrid.getSelectedItems(auiGridRight);
		// 옵션 목록에서 선택됐는지
		if(getSeqNo() == "" || selectedRowItems.length <= 0) {
			alert("옵션목록에서 선택해주세요.");
			return;
		}
		var frm = document.main_form;
		if($M.validation(frm, {field:["machine_plant_seq", "seq_no"]}) == false) {
			return;
		}
		var param = {
				"machine_plant_seq" : $M.getValue("machine_plant_seq"),
				"seq_no" : getSeqNo()
		}
		var msg = "\""+selectedRowItems[0].item.item_name+"\"옵션을 삭제하시겠습니까?";
		$M.goNextPageAjaxMsg(msg, this_page + "/remove", $M.toGetParam(param), { method : "POST"},
			function(result) {
				if(result.success) {
					goSearchBasicItem(getMachinePlantSeq());
				}
			}
		);
	}

	// 파일찾기 팝업
	function goSearchFile() {
		if($M.getValue("machine_plant_seq") == "") {
			alert("장비모델을 선택해주세요.");
			return;
		}
		var param = {
			upload_type	: "MACHINE",
			file_type : "img"
		};
		openFileUploadPanel('setFileInfo', $M.toGetParam(param));
	}
	
	// 팝업창에서 받아온 값
	function setFileInfo(result) {
		$("#file_name_item_div").remove();
		showFileNameTd();
		var str = '';
		str += '<div class="table-attfile-item" id="file_name_item_div">';
		str += '<a href="javascript:fileDownload(' + result.file_seq + ');" style="color: blue;">' + result.file_name + '</a>&nbsp;';
		str += '<input type="hidden" id="file_seq" name="file_seq" value="' + result.file_seq + '"/>';
		str += '<button type="button" class="btn-default" onclick="javascript:fnRemoveFile();"><i class="material-iconsclose font-18 text-default"></i></button>';
		str += '</div>';
		$("#file_name_div").append(str);
	}
	
	// 이미지 삭제
	function fnRemoveFile() {
		var result = confirm("이미지파일을 삭제하시겠습니까?");
		if (result) {
			showFileSearchTd();
			$("#file_name_item_div").remove();
		} else {
			return false;
		}
	}
	
	// 장비 조회
	function goSearch() {
		setMachinePlantSeq("");
		fnNew();
		var param = {
			"s_maker_cd" : $M.getValue("s_maker_cd"),
			"s_machine_name" : $M.getValue("s_machine_name")
		};
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					$("#total_cnt").html(result.total_cnt);
					AUIGrid.setGridData(auiGridLeft, result.list);
					AUIGrid.setGridData(auiGridRight, []);
				};
			}
		);
	}

	// 장비 기본지급품 조회
	function goSearchBasicItem(machine_plant_seq) {
		fnNew();
		$M.goNextPageAjax(this_page + "/search/"+machine_plant_seq, '', {method : 'get'},
			function(result) {
				if(result.success) {
					AUIGrid.setGridData(auiGridRight, result.list);
				}
			}
		);
	}
	
	// 입력 폼 초기화
	function fnNew() {
		setSeqNo("");
		$M.clearValue({field : ["item_name", "qty", "sort_no", "remark"]});
		showFileSearchTd();
		AUIGrid.clearSelection(auiGridRight);
	}
	
	// 파일찾기 버튼 노출
	function showFileSearchTd() {
		$("#file_search_td").removeClass("dpn");
		$("#file_name_td").addClass("dpn");
	}
	
	// 파일명 노출
	function showFileNameTd() {
		$("#file_search_td").addClass("dpn");
		$("#file_name_td").removeClass("dpn");
	}
	
	function setMachinePlantSeq(machine_plant_seq) {
		$M.setValue("machine_plant_seq", machine_plant_seq);
	}
	
	function getMachinePlantSeq() {
		return $M.getValue("machine_plant_seq");
	}
	
	function setSeqNo(seqNo) {
		$M.setValue("seq_no", seqNo);
	}
	
	function getSeqNo() {
		return $M.getValue("seq_no");
	}
	
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="machine_plant_seq" name="machine_plant_seq" value="" required="required" alt="장비"/>
<input type="hidden" id="seq_no" name="seq_no" value="0" />
<div class="layout-box">
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
				<!-- 메인 타이틀 -->
				<div class="main-title">
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
				<!-- /메인 타이틀 -->
				<div class="contents">
					<div class="row">
						<!-- 검색영역 -->					
						<div class="search-wrap">				
							<table class="table">
								<colgroup>
									<col width="50px">
									<col width="100px">
									<col width="40px">
									<col width="100px">
									<col width="">
								</colgroup>
								<tbody>
									<tr>
										<th>메이커</th>
										<td>
											<select class="form-control" id="s_maker_cd" name="s_maker_cd">
												<option value="">- 전체 -</option>
												<c:forEach items="${codeMap['MAKER']}" var="item">
													<c:if test="${item.code_v1 eq 'Y' && item.code_v2 eq 'Y'}">
														<option value="${item.code_value}">${item.code_name}</option>
													</c:if>
												</c:forEach>
											</select>
										</td>
										<th>모델</th>
										<td>
											<input type="text" class="form-control" id="s_machine_name" name="s_machine_name">
										</td>
										<td>
											<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
										</td>			
									</tr>										
								</tbody>
							</table>					
						</div>
						<!-- /검색영역 -->	
						<div class="col-5">
							<!-- 조회결과 -->
							<div class="title-wrap mt10">
								<h4>조회결과</h4>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_L"/></jsp:include>
							</div>
							<div id="auiGridLeft" style="margin-top: 5px; height: 385px; "></div>
						<!-- /조회결과 -->
						</div>
						<div class="col-7">
							<!-- 옵션목록 -->
							<div class="title-wrap mt10">
								<h4>옵션목록</h4>
								<div class="btn-group">
									<div class="right">
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
									</div>
								</div>
							</div>
							<div id="auiGridRight" style="margin-top: 5px; height: 300px; "></div>	
							<!-- /옵션목록 -->
							<!-- 폼테이블 -->					
							<table class="table-border mt10">
								<colgroup>
									<col width="80px">
									<col width="">
									<col width="80px">
									<col width="">
									<col width="80px">
									<col width="">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right">품명</th>
										<td>
											<input type="text" class="form-control" id="item_name" name="item_name" required="required" alt="품명">
										</td>		
										<th class="text-right">수량</th>
										<td>
											<input type="text" class="form-control text-right width50px" id="qty" name="qty" required="required" format="num" alt="수량">
										</td>	
										<th class="text-right">정렬순서</th>
										<td>
											<input type="text" class="form-control text-right width50px" id="sort_no" name="sort_no" required="required" format="num" alt="정렬순서">
										</td>						
									</tr>
									<tr>
										<th class="text-right">비고</th>
										<td colspan="3">
											<input type="text" class="form-control" placeholder="" id="remark" name="remark" alt="비고">
										</td>		
										<th class="text-right">이미지</th>
										<td id="file_search_td">
											<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
										</td>	
										<td id="file_name_td" class="dpn">
											<div class="table-attfile" id="file_name_div">
											</div>
										</td>				
									</tr>
								</tbody>
							</table>				
							<!-- /폼테이블 -->	
						</div>
					</div>
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt" >0</strong>건
						</div>					
					</div>
					<div class="btn-group mt5">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>					
					</div>
				</div>						
			</div>	
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>	
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>