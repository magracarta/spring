<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객 App관리 > 부품컨텐츠관리 
-- 작성자 : 정윤수
-- 최초 작성일 : 2023-07-12 16:53:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var page = 1;
		var moreFlag = "N";
		var isLoading = false;
		var auiGrid;
				
		$(document).ready(function() {
			fnInit();
		});

		function fnInit() {
			createAUIGrid();
			$("#_goPreview").prop("disabled", true);
		}
		// 조회
		function goSearch() {
			// 조회 버튼 눌렀을경우 1페이지로 초기화
			page = 1;
			moreFlag = "N";
			fnSearch(function(result){
				AUIGrid.setGridData(auiGrid, result.list);
				$("#total_cnt").html(result.total_cnt);
				$("#curr_cnt").html(result.list.length);
				if (result.more_yn == 'Y') {
					moreFlag = "Y";
					page++;
				};
			});
		}
		
		// 스크롤 위치가 마지막과 일치한다면 추가 데이터 요청함
		function fnScollChangeHandelr(event) {
			if(event.position == event.maxPosition && moreFlag == "Y" && isLoading == false) {
				goMoreData();
			};
		}

		function goMoreData() {
			fnSearch(function(result){
				result.more_yn == "N" ? moreFlag = "N" : page++;
				if (result.list.length > 0) {
					AUIGrid.appendData("#auiGrid", result.list);
					$("#curr_cnt").html(AUIGrid.getGridData(auiGrid).length);
				};
			});
		}

		//조회
		function fnSearch(successFunc) {
			isLoading = true;
			var param = {
				"s_part_no" : $M.getValue("s_part_no"),
				"s_part_name" : $M.getValue("s_part_name"),
				"s_sale_yn" : $M.getValue("s_sale_yn"),
				"s_use_yn" : $M.getValue("s_use_yn"),
				"page" : page,
				"rows" : $M.getValue("s_rows")
			};
			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
					function(result){
						isLoading = false;
						if(result.success) {
							fnClear();
							successFunc(result);
						};
					}
			);
		}
		// 상세정보 초기화
		function fnClear(){
			var param = {
				'part_no' : '',
				'machine_plant_seq' : '',
				'sale_yn' : '',
				'rep_file_seq' : '0',
				'add_file_seq_1' : '0',
				'add_file_seq_2' : '0',
				'add_file_seq_3' : '0',
				'part_name' : '',
				'c_part_pos_cd_str' : '',
				'desc_text' : '',
			}
			$(".rep_file").remove(); // 대표이미지 영역 초기화
			$(".attAddFileDiv").remove(); // 추가이미지 영역 초기화
			$M.setValue(param);
			$(".part_comm_list").remove();
			$("#_goPreview").prop("disabled", true);
			
		}
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_part_no", "s_part_name", "s_use_yn", "s_sale_yn"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}
		
		// 저장
		function goSave() {
			var partNo = $M.getValue("part_no");
			if (partNo == "") {
				alert("저장할 대상이 없습니다.");
				return;
			}
			var frm = document.main_form;

			var addIdx = 1;
			$("input[name='add_file_seq']").each(function() {
				if ($(this).attr("id") == undefined || $(this).attr("id") == '') {
					$M.setValue('add_file_seq_' + addIdx, $(this).val());
				}
				addIdx++;
			});
			for(; addIdx <= addFileCount; addIdx++) {
				$M.setValue('add_file_seq_' + addIdx, 0);
			}

			$M.setValue("c_part_pos_cd_str", $M.getValue("c_part_pos_cd_str").replaceAll("#", "^"));
			frm = $M.toValueForm(frm);
			$M.goNextPageAjaxSave(this_page + "/save", frm, {method: 'POST'},
					function (result) {
						if (result.success) {
							var partNo = $M.getValue("part_no");
							goSearchPartDetail(partNo);
						}
						;
					}
			);
		}
		
		// 첨부파일 출력
		function fnPrintFile(fileSeq, fileName) {
			var str = '';
			str += '<div class="table-attfile-item rep_file" style="float:left; display:block;">';
			str += '<a href="javascript:fileDownload(' + fileSeq + ');" style="color: blue; vertical-align: middle;">' + fileName + '</a>&nbsp;';
			str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveFile()"><i class="material-iconsclose font-16 text-default"></i></button>';
			str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
			str += '</div>';
			$('.rep_file_div').append(str);
			
			$M.setValue('rep_file_seq', fileSeq);
		}

		// 첨부파일 버튼 클릭
		function fnAddFile(){
			var partNo = $M.getValue("part_no");
			if (partNo == "") {
				alert("부품을 선택해주세요.");
				return;
			}
			if($("input[name='rep_file_seq']").size() >= 1 && $M.getValue("rep_file_seq") != "0" && $M.getValue("rep_file_seq") != "") {
				alert("대표이미지 파일은 1개만 첨부하실 수 있습니다.");
				return false;
			}
			
			openFileUploadPanel('setFileInfo', 'upload_type=PART&file_type=img&max_size=10240&max_width=450&max_height=500&img_resize=500');
		}

		function setFileInfo(result) {
			fnPrintFile(result.file_seq, result.file_name);
		}

		// 첨부파일 삭제
		function fnRemoveFile() {
			var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
			if (result) {
				$(".rep_file").remove();
				$M.setValue('rep_file_seq', 0);
			} else {
				return false;
			}
		}

		// 추가이미지 첨부파일 index 변수
		var addFileIndex = 1;
		// 추가이미지 첨수할 수 있는 파일의 개수
		var addFileCount = 3;

		// 추가이미지 파일추가
		function goAddFileForAddPopup() {
			var partNo = $M.getValue("part_no");
			if (partNo == "") {
				alert("부품을 선택해주세요.");
				return;
			}
			if($("input[name='add_file_seq']").size() >= addFileCount) {
				alert("추가이미지 파일은 " + addFileCount + "개만 첨부하실 수 있습니다.");
				return false;
			}

			var addFileSeqArr = [];
			var addFileSeqStr = "";
			$("[name=add_file_seq]").each(function() {
				addFileSeqArr.push($(this).val());
			});

			addFileSeqStr = $M.getArrStr(addFileSeqArr);

			var addFileParam = "";
			if("" != addFileSeqStr) {
				addFileParam = '&file_seq_str='+addFileSeqStr;
			}

			openFileUploadMultiPanel('setAddFileInfo', 'upload_type=PART&file_type=img&total_max_count=3&img_resize=716'+addFileParam);
		}

		// 추가이미지 파일세팅
		function setAddFileInfo(result) {
			$(".attAddFileDiv").remove(); // 파일영역 초기화
			addFileIndex = 1;
			var addFileList = result.fileList;  // 공통 파일업로드(다중) 에서 넘어온 file list
			for (var i = 0; i < addFileList.length; i++) {
				if(addFileList[i].file_seq != ""){
					fnPrintAddFile(addFileList[i].file_seq, addFileList[i].file_name);
				}
			}
		}

		// 추가이미지 첨부파일 출력 (멀티)
		function fnPrintAddFile(fileSeq, fileName) {
			var str = '';
			str += '<div class="table-attfile-item add_file_' + addFileIndex + ' attAddFileDiv"style="float:left; display:block;">';
			str += '<a href="javascript:fileDownload(' + fileSeq + ');" style="color: blue; vertical-align: middle;">' + fileName + '</a>&nbsp;';
			str += '<input type="hidden" name="add_file_seq" value="' + fileSeq + '"/>';
			str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveAddFile(' + addFileIndex + ', ' + fileSeq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
			str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
			str += '</div>';
			$('.add_file_div').append(str);
			addFileIndex++;
		}

		// 추가이미지 첨부파일 삭제
		function fnRemoveAddFile(fileIndex, fileSeq) {
			var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
			if (result) {
				// fileChangeYn = 'Y';
				$(".add_file_" + fileIndex).remove();
				addFileIndex--;
			} else {
				return false;
			}
		}


		// 부품위치코드관리 팝업
		function goPartPosCdMngPopup() {
			var param = {
				group_code : "C_PART_POS",
				all_yn : 'Y',
			}
			openGroupCodeDetailPanel($M.toGetParam(param));
		}
		
		function goSearchPartPos() {
			
		}
		
		// 부품위치 별 조회화면 미리보기 팝업
		function goPreview() {
			var machinePlantSeq = $M.getValue("machine_plant_seq");
			
			var param = {
				"machine_plant_seq" : machinePlantSeq,
				"part_no" : $M.getValue("part_no"),
				"part_name" : $M.getValue("part_name"),
				"sale_price" : $M.getValue("sale_price"),
				"vip_sale_price" : $M.getValue("vip_sale_price"),
				"rep_file_seq" : $M.getValue("rep_file_seq"),
				"c_part_pos_cd_str" : $M.getValue("c_part_pos_cd_str")
			};
			var popupOption = "";
			$M.goNextPage('/cust/cust0504p01', $M.toGetParam(param), {popupStatus : popupOption});
		}
		
		// 부품마스터 팝업
		function goDetail() {
			var popupOption = "";
			var param = {
				"part_no" : $M.getValue("part_no")
			};
			if(param.part_no == ""){
				alert("부품을 선택해주세요.");
				return
			}else {
				$M.goNextPage('/part/part0701p01', "part_no=" + param.part_no, {popupStatus : popupOption});
			}
		}

		
		// 부품컨텐츠 그리드
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				editable : false,
				enableMovingColumn : false,
			};
			var columnLayout = [
				{
					headerText : "부품번호",
					dataField : "part_no",
					width : "140",
					minWidth : "60",
					style : "aui-center aui-popup",
					editable : false,
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "부품명",
					dataField : "part_name",
					style : "aui-center aui-popup",
					editable : false,
					filter : {
						showIcon : true
					},
				},
				{
					headerText : "사용여부",
					dataField : "use_yn",
					width : "80",
					minWidth : "50",
					style : "aui-center",
					editable : false,
				},
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);

			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				var poppupOption = "scrollbars=no, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=550, left=0, top=0";
				var param = {
					"part_no" : event.item["part_no"]
				};
				if(event.dataField == 'part_no'){ // 부품번호 클릭 시 부품마스터
					$M.goNextPage('/part/part0701p01', $M.toGetParam(param), {popupStatus : poppupOption});
				} else if(event.dataField == 'part_name'){
					$M.setValue("part_no", event.item.part_no);
					var partNo =  event.item.part_no;
					goSearchPartDetail(partNo);
				}
			});
			AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
		}
		
		// 부품명 클릭 시 해당부품 고객 앱 부품정보 조회
		function goSearchPartDetail(partNo){
			$M.goNextPageAjax(this_page +"/search/" + partNo + "/", '', '',
					function(result) {
						if(result.success) {
							var row = result.detail;
							$(".rep_file").remove(); // 대표이미지 영역 초기화
							$(".attAddFileDiv").remove(); // 추가이미지 영역 초기화
							if(row.rep_file_seq != ""){
								fnPrintFile(row.rep_file_seq, row.rep_file_name); // 대표이미지 세팅
							}
							setAddFileInfo(result); // 추가이미지 세팅
							$M.setValue(row);
							$M.setValue("machine_plant_seq", result.partMchList[0].machine_plant_seq);
							// 조회한 부품의 부품위치코드, 모델명 세팅
							var partPosCdArr = row.c_part_pos_cd_str.split("^");
							$('#c_part_pos_cd_str').combogrid("setValues", partPosCdArr);

							$(".part_comm_list").remove();
							var str = '';
							str += '<ul class="part_comm_list">'
							for(var i=0; i<result.partMchList.length; i++){
								str += '<li class="profilephoto-delete">'+ result.partMchList[i].machine_name + '</li>'
							}
							str += '</ul>'
							$('.part_comm_div').append(str);
							
							if($M.getValue("machine_plant_seq") == ""){
								$("#_goPreview").prop("disabled", true);
							} else {
								$("#_goPreview").prop("disabled", false);
							}
						}
					});
		}
		
		function goPartNameDetail() {
			var param = {
			};
			var popupOption = "";
			$M.goNextPage('/cust/cust0504p02', $M.toGetParam(param), {popupStatus : popupOption});
		}
	</script>
	<style>
		ul.part_comm_list {display: flex; flex-wrap: wrap;}
		ul.part_comm_list li {padding: 5px 10px 5px 10px; border: 1px solid #e7e7e7; margin: 3px; color: #666; border-radius: 30px; background: #f7f7f7;}
	</style>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="part_no" name="part_no">
<input type="hidden" id="machine_plant_seq" name="machine_plant_seq">
<input type="hidden" id="sale_yn" name="sale_yn" value="Y">
<input type="hidden" id="rep_file_seq" name="rep_file_seq" value=""/>
<input type="hidden" id="add_file_seq_1" name="add_file_seq_1" value=""/>
<input type="hidden" id="add_file_seq_2" name="add_file_seq_2" value=""/>
<input type="hidden" id="add_file_seq_3" name="add_file_seq_3" value=""/>
<input type="hidden" id="sale_price" name="sale_price" value=""/>
<input type="hidden" id="vip_sale_price" name="vip_sale_price" value=""/>
<input type="hidden" id="apply_st_dt" name="apply_st_dt" value=""/>
<input type="hidden" id="seq_no" name="seq_no" value=""/>
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
				<!-- 검색영역 -->
				<div class="search-wrap">
					<table class="table">
						<colgroup>
							<col width="70px">
							<col width="130px">
							<col width="70px">
							<col width="130px">
							<col width="70px">
							<col width="100px">
							<col width="*">
						</colgroup>
						<tbody>
						<tr>
							<th>부품번호</th>
							<td>
								<input type="text" class="form-control" id="s_part_no" name="s_part_no">
							</td>
							<th>부품명</th>
							<td>
								<input type="text" class="form-control" id="s_part_name" name="s_part_name">
							</td>
							<th>사용여부</th>
							<td>
								<select class="form-control" id="s_use_yn" name="s_use_yn">
									<option value="">전체</option>
									<option value="Y" selected="selected">사용</option>
									<option value="N">미사용</option>
								</select>
							</td>
							<td class="">
								<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
							</td>
						</tr>
						</tbody>
					</table>
				</div>
				<!-- /검색영역 -->
				<div class="row">
					<!-- 버튼목록 -->
					<div class="col-6">
						<div class="title-wrap mt10">
							<h4>조회결과</h4>
						</div>
						<div id="auiGrid" style="margin-top: 5px; height: 465px;"></div>
						<!-- 그리드 서머리, 컨트롤 영역 -->
						<div class="btn-group mt5">
							<div class="left">
								<jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
							</div>
						</div>
						<!-- /그리드 서머리, 컨트롤 영역 -->
					</div>
					<!-- /버튼목록 -->
					<div class="col-6">
						<div class="row">
							<!-- 버튼정보 -->
							<div class="col-12">
								<div class="title-wrap mt10">
									<h4>상세정보</h4>
									<div class="btn-group mt5">
										<div class="right">
											<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
										</div>
									</div>
								</div>
								<!-- 폼테이블 -->
								<div>
									<table class="table-border mt5">
										<colgroup>
											<col width="100px">
											<col width="">
											<col width="100px">
											<col width="">
										</colgroup>
										<tbody>
										<tr>
											<th class="text-right">대표이미지</th>
											<td>
												<div class="table-attfile rep_file_div" style="width:100%;">
													<div class="table-attfile" style="float:left">
														<button type="button" class="btn btn-primary-gra mr10" name="fileAddBtn" id="fileAddBtn" onclick="javascript:fnAddFile();">파일찾기</button>
													</div>
												</div>
											</td>
                                            <th class="text-right">사용여부</th>
                                            <td>
                                                <div class="form-check form-check-inline">
                                                    <input class="form-check-input" type="radio"
                                                           name="use_yn" id="use_y" value="Y" checked="checked">
                                                    <label for="use_y" class="form-check-label">Y</label>
                                                </div>
                                                <div class="form-check form-check-inline">
                                                    <input class="form-check-input" type="radio"
                                                           name="use_yn" id="use_n" value="N"> <label
                                                        for="use_n" class="form-check-label">N</label>
                                                </div>
                                            </td>
										</tr>
										<tr>
                                            <th class="text-right">추가이미지</th>
                                            <td colspan="3">
                                                <div class="table-attfile add_file_div" style="width:100%;">
                                                    <div class="table-attfile" style="float:left">
                                                        <button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goAddFileForAddPopup();">파일찾기</button>
                                                    </div>
                                                </div>
                                            </td>
										</tr>
										<tr>
											<th class="text-right">서비스 연관부품</th>
											<td colspan="3">
												<div class="form-check form-check-inline">
													<input class="form-check-input" type="radio"
														   name="svc_yn" id="svc_y" value="Y" checked="checked">
													<label for="svc_y" class="form-check-label">Y</label>
												</div>
												<div class="form-check form-check-inline">
													<input class="form-check-input" type="radio"
														   name="svc_yn" id="svc_n" value="N"> <label
														for="svc_n" class="form-check-label">N</label>
												</div>
											</td>
										</tr>
										<tr>
											<th class="text-right">호환모델</th>
											<td colspan="3">
												<div  class="form-row inline-pd">
													<div class="col-12 part_comm_div">
													</div>
												</div>
											</td>
										</tr>
										<tr>
											<th class="text-right">앱 용 부품명</th>
											<td colspan="3">
												<input type="text" class="form-control" id="part_name" name="part_name" maxlength="100">
											</td>
										</tr>
										<tr>
											<th class="text-right">부품위치지정</th>
											<td colspan="3">
												<div class="form-row inline-pd pr">
													<div class="col-4">
														<input class="form-control" style="width: 99%;"type="text"
															   id="c_part_pos_cd_str"
															   name="c_part_pos_cd_str"
															   easyui="combogrid"
															   easyuiname="partPosCd"
															   panelwidth="210"
															   idfield="code_value"
															   textfield="code_name"
															   multi="Y"/>
<%--														<select class="form-control" id="c_part_pos_cd" name="c_part_pos_cd">--%>
<%--															<option value="">선택</option>--%>
<%--															<c:forEach items="${codeMap['C_PART_POS']}" var="item">--%>
<%--																<option value="${item.code_value}" <c:if test="${result.c_part_pos_cd == item.code_value}">selected</c:if>>${item.code_name}</option>--%>
<%--															</c:forEach>--%>
<%--														</select>--%>
													</div>
													<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
												</div>
											</td>
										</tr>
										<tr>
											<th class="text-right">부품상세설명</th>
											<td colspan="3">
												<textarea class="form-control" style="height: 117px; resize: none;" id="desc_text" name="desc_text" maxlength="500"></textarea>
											</td>
										</tr>
										</tbody>
									</table>
								</div>
								<!-- /폼테이블 -->
								<!-- 그리드 서머리, 컨트롤 영역 -->
								<div class="btn-group mt5">
									<div class="right">
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
									</div>
								</div>
								<!-- /그리드 서머리, 컨트롤 영역 -->
							</div>
							<!-- /버튼정보 -->
						</div>
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